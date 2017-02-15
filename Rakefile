require "bundler/gem_helper"
require "rake/testtask"
require "yard"

task :default => :test

desc "Build ultimaker and ultimaker-discovery into the pkg directory"
task "build" => %W[ultimaker:build ultimaker-discovery:build]

desc "Clean up the pkg directory"
task "clean" do
  FileUtils.rm_rf("pkg")
end

namespace "docs" do
  YARD::Rake::YardocTask.new do |t|
    t.after = ->() { FileUtils.touch("docs/.nojekyll") }
    t.files = FileList["lib/**/*.rb"] + ["-", "LICENSE"]
    t.name = "build"
    t.options = %W[--output-dir docs]
  end
end

desc "Build and install ultimaker and ultimaker-discovery into system gems"
task "install" => %W[ultimaker:install ultimaker-discovery:install]

desc "Create tag and push ultimaker and ultimaker-discovery to Rubygems"
task "release" => %W[ultimaker:release ultimaker-discovery:release]

Rake::TestTask.new(:test) do |t|
  t.libs << "lib" << "test"

  if (ENV["DNSSD"] == "1" || RUBY_PLATFORM[/darwin/]) && ENV["DNSSD"] != "0"
    t.test_files = FileList["test/**/*_test.rb"]
  else
    t.test_files = FileList["test/**/*_test.rb"].reject { |f| f =~ /discovery/ }
  end
end

namespace "ultimaker" do
  Bundler::GemHelper.install_tasks(name: "ultimaker")
end

namespace "ultimaker-discovery" do
  Bundler::GemHelper.install_tasks(name: "ultimaker-discovery")
end
