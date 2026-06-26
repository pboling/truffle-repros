# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  gem "citrus", "~> 3.0"
  gem "parslet", "~> 2.0"
end

normal_require_failures = []

%w[citrus parslet].each do |feature|
  begin
    require feature
    puts "required #{feature}"
  rescue TypeError => e
    normal_require_failures << [feature, e]
  end
end

if normal_require_failures.any?
  puts "CURRENT ISSUE: normal require raised TypeError"
  normal_require_failures.each do |feature, error|
    puts "#{feature}: #{error.class}: #{error.message}"
    puts error.backtrace.first(8)
  end
  exit 2
end

begin
  require "bundled_gems"
  if defined?(Gem::BUNDLED_GEMS) && Gem::BUNDLED_GEMS.respond_to?(:warning?)
    Gem::BUNDLED_GEMS.warning?(nil)
    puts "internal warning?(nil): no TypeError"
  else
    puts "internal warning?(nil): unavailable"
  end
rescue TypeError => e
  puts "context only: internal warning?(nil) raises #{e.class}: #{e.message}"
end

puts "PASS no active issue: normal parser-gem requires did not raise TypeError"
