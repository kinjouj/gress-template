$:.unshift "./lib"
require "bundler/setup"
Bundler.require(:default, :test)

require "rake/clean"
require "rspec/core/rake_task"
require "gress"

RSpec::Core::RakeTask.new("spec")
config = Gress::Config.instance

task :build do
  CLEAN.include("public/*")
  Rake::Task["clean"].invoke
  Rake::Task["build_assets"].invoke
  result = Benchmark.realtime {
    GC.disable
    Gress.build(config)
    GC.enable
  }
  Rake::Task["build_sitemap"].invoke if config.mode == "html"
  NotifySend.send "build complete", "build complete: #{result}sec", "info", 5000
  puts "build time: #{result}"
end

task :build_assets do
  cp_r "static/.", "public"
  sh "./node_modules/.bin/lessc source/css/* public/css/site.css", verbose: false
end

task :build_sitemap do
  files = []

  cd "public" do
    files = Dir.glob("*/**/*.html")
  end

  SitemapGenerator::Sitemap.default_host = "https://kinjouj.github.io"
  SitemapGenerator::Sitemap.sitemaps_path = "./"
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
  SitemapGenerator::Sitemap.create(:compress => false) do
    files.sort.each do |file|
      next if file.match(/^archive/)
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
        sh "guard --no-interactions --no-bundler-warning", verbose: false
      }
    end
  }
end

task :preview do
  pid = nil

  loop {
    if !pid.nil?
      Rake::Task["server"].execute
    else
      pid = fork {
        Rake::Task["build"].execute
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
    sh "git init"
    sh "git remote add origin #{config.repository}"
  end
end

task :github_deploy do
  cd "public" do
    sh "git add -A", verbose: false
    sh "git commit -m \"Site updated at #{Time.now.utc}\"", verbose: false
    sh "git push origin master", verbose: false
  end
end
