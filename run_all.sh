#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS=(
  "ruby@truffleruby+graalvm-33.0.1"
  "ruby@truffleruby+graalvm-34.0.0"
)

REPROS=(
  "ffi-missing-library"
  "ffi-struct-by-value"
  "bundled-gems-file-path-nil"
  "bundler-unbundled-env-thread"
  "appraisal2-dsl-generation"
  "appraisal2-bundler-lock"
)

status=0

for version in "${VERSIONS[@]}"; do
  echo "## ${version}"
  mise exec -C "$ROOT" "$version" -- ruby -v || {
    status=1
    continue
  }

  for repro in "${REPROS[@]}"; do
    echo
    echo "### ${repro}"
    if ! mise exec -C "$ROOT/$repro" "$version" -- ruby repro.rb; then
      status=1
    fi
  done
  echo
done

exit "$status"
