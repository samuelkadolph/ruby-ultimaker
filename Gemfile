source "https://rubygems.org"

gemspec name: "ultimaker"

gem "rake"
gem "yard"

group :test do
  gem "minitest"
  gem "mocha"
end

if (ENV["DNSSD"] == "1" || RUBY_PLATFORM[/darwin/]) && ENV["DNSSD"] != "0"
  gem "dnssd"
end
