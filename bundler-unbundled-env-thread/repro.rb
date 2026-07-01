# frozen_string_literal: true

require "bundler"

THREADS = Integer(ENV.fetch("REPRO_THREADS", "4"))
ITERATIONS = Integer(ENV.fetch("REPRO_ITERATIONS", "200"))

ENV["BUNDLE_GEMFILE"] = File.expand_path("Gemfile", __dir__)
ENV["BUNDLE_BIN_PATH"] ||= "synthetic-bundle-bin-path"
ENV["RUBYOPT"] ||= "-rbundler/setup"

errors = Queue.new

workers = Array.new(THREADS) do |thread_index|
  Thread.new do
    ITERATIONS.times do
      Bundler.with_unbundled_env do
        Thread.pass
      end
    end
  rescue Exception => error # rubocop:disable Lint/RescueException -- repro must report VM/internal failures too.
    errors << [thread_index, error]
  end
end

workers.each(&:join)

if errors.empty?
  puts "PASS #{RUBY_DESCRIPTION}"
  puts "threads=#{THREADS} iterations=#{ITERATIONS}"
  exit 0
end

puts "FAIL #{RUBY_DESCRIPTION}"
until errors.empty?
  thread_index, error = errors.pop
  puts "thread=#{thread_index} #{error.class}: #{error.message}"
  puts Array(error.backtrace).first(12)
end
exit 2
