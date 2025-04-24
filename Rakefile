$:.unshift "./lib"

require "gress"
require "rake/clean"
require "rspec/core/rake_task"

CLEAN.include("public/*")

config = Gress::Config.parse("config.json")

task :build do
  Rake::Task["clean"].invoke
  cp_r "static/.", "public"
  Gress::Generator.generate("config.json")

  if config.mode == "html"
    #sh "npm run build"
    #Rake::Task["build_sitemap"].invoke
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

task :preview do
  pid = nil

  loop {
    if !pid.nil?
      Rake::Task["server"].execute
    else
      pid = fork {
        sh "rake build"
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
