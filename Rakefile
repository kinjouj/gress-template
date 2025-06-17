# frozen_string_literal: true

$LOAD_PATH.unshift "./lib"

require "bundler/setup"
Bundler.require(:default, :test)

require "rake/clean"
require "rspec/core/rake_task"
require "rubocop/rake_task"
RuboCop::RakeTask.new
RSpec::Core::RakeTask.new("spec")

require "gress"

desc "build"
task :build do
  CLEAN.include("public/*")
  Rake::Task["clean"].invoke
  Rake::Task["build_assets"].invoke
  result = Benchmark.realtime do
    GC.disable
    Gress.build
    GC.enable
  end
  Rake::Task["build_sitemap"].invoke if Gress::Config[:mode] == "html"
  NotifySend.send "build complete", "build complete: #{result}sec", "info", 5000
  puts "build time: #{result}"
end

desc "build_assets"
task :build_assets do
  cp_r "static/.", "public"
  files = Dir.glob("scss/*")
  files.each do |file|
    basename = File.basename(file, ".scss")
    scss = Sass.compile(file)
    File.write("public/css/#{basename}.css", scss.css)
  end
end

desc "build_sitemap"
task :build_sitemap do
  files = []
  cd "public" do
    files = Dir.glob("**/*.html")
  end

  SitemapGenerator::Sitemap.default_host = Gress::Config["host"]
  SitemapGenerator::Sitemap.sitemaps_path = "./"
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
  SitemapGenerator::Sitemap.create(compress: false) do
    files.sort.each do |file|
      next if file.match(/^archive|category/)

      add file, changefreq: "always", priority: "1.0"
    end
  end
end

desc "watch"
task :watch do
  pid = nil

  loop do
    if pid.nil?
      pid = fork { sh "guard --no-interactions --no-bundler-warning", verbose: false }
    else
      Rake::Task["server"].execute
    end
  end
end

desc "preview"
task :preview do
  pid = nil

  loop do
    if pid.nil?
      pid = fork { Rake::Task["build"].execute }
    else
      Rake::Task["server"].execute
    end
  end
end

desc "server"
task :server do
  rackup_pid = Process.spawn("ruby -run -e httpd public -p 4000")
  trap("INT") do
    Process.kill(9, rackup_pid) rescue Errno::ESRCH
    exit 0
  end
  Process.wait(rackup_pid)
end

task :github_setup do
  cd "public" do
    sh "git init", verbose: false
    sh "git remote add origin #{Gress::Config[:repository]}", verbose: false
  end
end

task :github_deploy do
  cd "public" do
    sh "git add -A", verbose: false
    sh "git commit -m \"Site updated at #{Time.now.utc}\"", verbose: false
    sh "git push origin master", verbose: false
  end
end
