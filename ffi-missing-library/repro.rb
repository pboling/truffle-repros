# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  gem "ffi", "~> 1.17"
end

require "ffi"

path = File.expand_path("tmp/does-not-exist/libmissing.so", __dir__)

begin
  FFI::DynamicLibrary.open(path, FFI::DynamicLibrary::RTLD_LAZY)
  abort "UNEXPECTED: opened missing library"
rescue LoadError => e
  puts "PASS no active issue: #{RUBY_ENGINE} raised LoadError: #{e.message.lines.first.strip}"
rescue RuntimeError => e
  puts "CURRENT ISSUE: #{RUBY_ENGINE} raised RuntimeError instead of LoadError"
  puts e.message.lines.first.strip
  exit 2
end
