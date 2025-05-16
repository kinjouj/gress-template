$:.unshift "./lib"
require "bundler/setup"
Bundler.require(:default, :test)

require "rake/clean"
require "rspec/core/rake_task"
require "gress"

RSpec::Core::RakeTask.new("spec")
config = Gress::Config.new

task :build do
  CLEAN.include("public/*")
  Rake::Task["clean"].invoke
  cp_r "static/.", "public"
  result = Benchmark.realtime {
    GC.disable
    Gress.build(config)
    GC.enable
  }
  Rake::Task["build_sitemap"].invoke if config.mode == "html"
  NotifySend.send "build complete", "build complete: #{result}sec", "info", 5000
  p "build time: #{result}"
end

task :build_sitemap do
  files = []

  cd "public" do
    files = glob("*/**/*.html")
  end

  SitemapGenerator::Sitemap.default_host = "https://kinjouj.github.io"
  SitemapGenerator::Sitemap.sitemaps_path = "./"
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
  SitemapGenerator::Sitemap.create(:compress => false) do
    files.each do |file|
      add file, :changefreq => "always", :priority => "1.0"
    end
  end
end

task :watch do
  pid = nil

  loop {
    if !pid.nil?
      Rake::Task["server"].execute
    else
      pid = fork {
        sh "guard --no-interactions --no-bundler-warning"
      }
    end
  }
end

task :server do
  rackupPid = Process.spawn("ruby -run -e httpd public -p 4000")
  trap("INT") {
    Process.kill(9, rackupPid) rescue Errno::ESRCH
    exit 0
  }
  Process.wait(rackupPid)
end

task :github_setup do
  cd "public" do
    system "git init"
    system "git remote add origin #{config.repository}"
  end
end

task :github_deploy do
  cd "public" do
    system "git add -A"
    system "git commit -m \"Site updated at #{Time.now.utc}\""
    system "git push origin master"
  end
end
