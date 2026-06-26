# frozen_string_literal: true

require "fileutils"
require "open3"
require "pathname"

APPRAISAL2_ROOT = File.expand_path("../../appraisal-rb/appraisal2", __dir__)
STAGE = File.expand_path("tmp/stage", __dir__)

FileUtils.rm_rf(STAGE)
FileUtils.mkdir_p(File.join(STAGE, "gemfiles"))

def run!(*cmd, env: {})
  stdout, stderr, status = Open3.capture3(env, *cmd, :chdir => STAGE)
  puts stdout unless stdout.empty?
  warn stderr unless stderr.empty?
  return [stdout, stderr, status] if status.success?

  raise "command failed (#{status.exitstatus}): #{cmd.join(" ")}"
end

def write(path, content)
  full_path = File.join(STAGE, path)
  FileUtils.mkdir_p(File.dirname(full_path))
  File.write(full_path, content)
end

write "dummy.gemspec", <<~GEMSPEC
  Gem::Specification.new do |s|
    s.name = "dummy"
    s.version = "1.0.0"
    s.summary = "dummy"
    s.authors = ["repro"]
    s.files = []
  end
GEMSPEC

write "Gemfile", <<~GEMFILE
  source "https://rubygems.org"
  gem "appraisal2", :path => "#{APPRAISAL2_ROOT}"
GEMFILE

write "Appraisals", <<~APPRAISALS
  appraise "bundler-locked" do
    gemspec
  end
APPRAISALS

write "gemfiles/bundler_locked.gemfile", <<~GEMFILE
  source "https://rubygems.org"
  gemspec :path => "../"
GEMFILE

begin
  run!("bundle", "install")
  run!("bundle", "install", "--gemfile", "gemfiles/bundler_locked.gemfile")

  lockfile_path = File.join(STAGE, "gemfiles/bundler_locked.gemfile.lock")
  lockfile = File.read(lockfile_path)
  active = lockfile[/BUNDLED WITH\s*\n\s*([^\s]+)/, 1] || raise("missing BUNDLED WITH")
  parts = active.split(".")
  if parts.last.to_i <= 0
    puts "SKIP inconclusive: active Bundler patch version #{active.inspect} cannot be decremented"
    exit 0
  end
  locked = parts.tap { |segments| segments[-1] = (segments[-1].to_i - 1).to_s }.join(".")
  File.write(lockfile_path, lockfile.sub(/(BUNDLED WITH\s*\n\s*)([^\s]+)/, "\\1#{locked}"))

  stdout, stderr, status = run!(
    "bundle",
    "exec",
    "appraisal",
    "bundler-locked",
    "install",
    env: {"APPRAISAL_UNDER_TEST" => "1"}
  )

  final_lock = File.read(lockfile_path)
  if status.success? && final_lock.match?(/BUNDLED WITH\s*\n\s*#{Regexp.escape(locked)}\b/)
    puts "PASS no active issue: Appraisal2 preserved locked Bundler #{locked}"
  else
    puts "CURRENT ISSUE: Appraisal2 did not preserve locked Bundler #{locked}"
    puts stdout
    warn stderr
    exit 2
  end
rescue StandardError => e
  puts "CURRENT ISSUE: Appraisal2 locked Bundler install failed on #{RUBY_ENGINE}"
  puts "#{e.class}: #{e.message}"
  puts e.backtrace.first(12)
  exit 2
end
