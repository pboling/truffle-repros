# frozen_string_literal: true

require "bundler/inline"
require "fileutils"

gemfile(true) do
  source "https://rubygems.org"
  gem "ffi", "~> 1.17"
end

require "ffi"

tmp = File.expand_path("tmp", __dir__)
FileUtils.mkdir_p(tmp)
c_path = File.join(tmp, "pair.c")
so_path = File.join(tmp, "libpair.so")

File.write(c_path, <<~C)
  typedef struct {
    int left;
    int right;
  } pair_t;

  pair_t make_pair(void) {
    pair_t pair = { 17, 25 };
    return pair;
  }
C

unless system("cc", "-shared", "-fPIC", c_path, "-o", so_path)
  abort "SETUP FAILURE: could not compile #{so_path}"
end

begin
  class Pair < FFI::Struct
    layout :left, :int,
      :right, :int
  end

  module PairLib
    extend FFI::Library
    ffi_lib File.expand_path("tmp/libpair.so", __dir__)
    attach_function :make_pair, [], Pair.by_value
  end

  pair = PairLib.make_pair
  if pair[:left] == 17 && pair[:right] == 25
    puts "PASS no active issue: struct-by-value returned #{pair[:left]}, #{pair[:right]}"
  else
    abort "UNEXPECTED: struct contents were #{pair[:left].inspect}, #{pair[:right].inspect}"
  end
rescue Exception => e # rubocop:disable Lint/RescueException
  puts "KNOWN CURRENT ISSUE: struct-by-value FFI call failed on #{RUBY_ENGINE}"
  puts "#{e.class}: #{e.message}"
  puts e.backtrace.first(8)
  exit 2
end
