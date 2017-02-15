require "bundler"
Bundler.setup(:default, :test)

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "ultimaker"

require "minitest/autorun"
require "mocha/mini_test"
