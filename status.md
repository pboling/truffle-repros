# TruffleRuby workaround catalogue

Prepared for review. One upstream issue has been filed from the validation pass:
`truffleruby/truffleruby#4345`.

## Scope and filters

- Workspace searched: `/home/pboling/src/my`
- Included:
    - specs using `skip_for` / `pending_for` with `truffleruby`
    - production/library code with TruffleRuby-specific branches, exceptions, or alternate routes
- Excluded from the actionable set:
    - generated docs / README matrix links
    - vendored upstream code
    - `tmp/` quarantine and scratch copies
    - ordinary engine support metadata that does not describe a workaround
- Raw inventory artifacts:
    - `truffleruby-inventory.txt`
    - `truffleruby-summary.txt`
    - `truffleruby-actionable.txt`
    - `truffleruby-current-open-issues.json`
    - `truffleruby-current-searches-v2.txt`

## Support-policy baseline used for triage

- TruffleRuby upstream repo: `https://github.com/truffleruby/truffleruby`
- TruffleRuby README says:
    - compatibility bugs should be reported to `github.com/truffleruby/truffleruby/issues`
    - version `AB.C.D` targets CRuby `A.B`
    - current compatibility table includes:
        - TruffleRuby `40.0.0` -> CRuby/Ruby `4.0`
        - TruffleRuby `34.0.0` -> CRuby/Ruby `3.4`
        - TruffleRuby `33.0.0` and `25.0.0` -> Ruby `3.3` era compatibility via GraalVM `25.0.x`
- Ruby branch support page currently classifies:
    - Ruby `4.0`: normal maintenance
    - Ruby `3.4`: normal maintenance
    - Ruby `3.3`: security maintenance, expected EOL `2027-03-31`
    - Ruby `3.2` and older: EOL

For reporting, I treated issues affecting TruffleRuby on Ruby `3.3`, `3.4`, or `4.0` compatibility levels as potentially reportable. Skips limited to Ruby `3.1..3.2` are not reportable unless they reproduce on a non-EOL compatibility level.

## Catalogue

### 1. `tree_haver` FFI backend disabled on TruffleRuby

- Files:
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/ffi.rb:47`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/ffi.rb:81`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/ffi.rb:92`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/ffi.rb:271`
- Local classification: production/library workaround.
- Local behavior: `ffi_gem_available?` returns `false` on `RUBY_ENGINE == 'truffleruby'` because tree-sitter uses FFI struct-by-value returns such as `ts_tree_root_node`, `ts_node_child`, and point-returning APIs.
- Upstream match: known open issue.
    - `#3835 Struct by value support for FFI`
    - `https://github.com/truffleruby/truffleruby/issues/3835`
    - labels: `compatibility`, `ffi`
- Reporting recommendation: do not file a duplicate. If useful, add a comment to #3835 with a minimal tree-sitter repro from `tree_haver` on a non-EOL TruffleRuby version.
- Priority: high for upstream tracking, low for new issue creation.

### 2. `tree_haver` TruffleRuby `bundled_gems.rb` / `File.path(nil)` TypeError rescue

- Files:
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/citrus_grammar_finder.rb:125`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/citrus_grammar_finder.rb:127`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/parslet_grammar_finder.rb:114`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/parslet_grammar_finder.rb:117`
- Local classification: production/library defensive workaround.
- Local behavior: rescues `TypeError` during grammar loading and warns that TruffleRuby bundled gems code may call `File.path` on `nil` when caller locations are nil.
- Upstream match: no specific open issue found in `truffleruby/truffleruby` for `bundled_gems`, `File.path`, or `TypeError bundled_gems`. Broadly related but not a match:
    - `#4069 Run tests of bundled gems` is a cleanup issue, not this bug.
    - `#4231 Ruby 4.0 support` is too broad.
- Reporting recommendation: candidate new issue, but only after reproducing on TruffleRuby `33.0`, `34.0`, or `40.0` (or current `dev`) with a minimal script showing:
    - exact TruffleRuby version
    - `require` path / grammar gem involved
    - full `TypeError` message and backtrace including `bundled_gems.rb`
    - whether the same script succeeds on CRuby for the matching Ruby version
- Priority: medium, because the current local workaround catches a broad `TypeError` and needs a concrete repro before filing.

### 3. `tree_haver` FFI shared-library failure can raise `RuntimeError` instead of `LoadError`

- File:
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/ffi.rb:473`
- Local classification: production/library exception-shape workaround.
- Local behavior: comment says TruffleRuby raises `RuntimeError` instead of `LoadError` when a shared library cannot be opened.
- Upstream match: no specific open issue found for `LoadError RuntimeError`, `shared library LoadError`, or similar searches in `truffleruby/truffleruby`.
- Reporting recommendation: candidate new issue only if reproduced on a non-EOL TruffleRuby version with a minimal `ffi_lib` script and expected CRuby/ffi behavior. This may be an `ffi` gem compatibility issue rather than TruffleRuby core, so confirm where the exception originates before filing.
- Priority: medium-low.

### 4. `appraisal2` full Bundler DSL compatibility specs skipped on all TruffleRuby

- Files:
    - `/home/pboling/src/my/appraisal-rb/appraisal2/spec/acceptance/gemfile_dsl_compatibility_spec.rb:5`
    - `/home/pboling/src/my/appraisal-rb/appraisal2/spec/acceptance/appraisals_file_bundler_dsl_compatibility_spec.rb:5`
    - `/home/pboling/src/my/appraisal-rb/appraisal2/spec/acceptance/appraisals_file_bundler_dsl_compatibility_spec.rb:165`
- Local classification: spec-only broad skip.
- Local behavior:
    - skips Gemfile/Appraisals Bundler DSL compatibility acceptance tests on all TruffleRuby versions.
    - The skipped specs cover git/path/source/group/platform/install_if/gemspec/ruby-file DSL generation.
- Upstream match: no specific open issue found for `appraisal bundler dsl`.
- Reporting recommendation: not ready to file. First run these specs on supported TruffleRuby (`33.0`, `34.0`, `40.0`, or current `dev`) and classify the actual failure. It may be:
    - Appraisal2 behavior
    - Bundler DSL compatibility
    - local fixture/platform assumptions
    - TruffleRuby compatibility
- Priority: medium. Broad all-version skip means this may still affect non-EOL versions, but the current evidence does not identify an upstream bug.

### 5. `appraisal2` Bundler version upgrade/install acceptance spec skipped on TruffleRuby

- File:
    - `/home/pboling/src/my/appraisal-rb/appraisal2/spec/acceptance/cli/named_appraisal_install_spec.rb:178`
- Local classification: spec-only skip with explicit runtime-policy reason.
- Local behavior: skips a test that verifies Appraisal respects `BUNDLED WITH` in generated appraisal lockfiles; reason says "Upgrading bundler on Truffleruby is not a thing".
- Upstream match: no specific current issue found for `bundle update --bundler` or RubyGems/Bundler upgrade. Broadly related but not equivalent:
    - `#1981 bundle exec creates an extra subprocess on TruffleRuby` is performance/process behavior, not Bundler upgrading.
    - `#4231 Ruby 4.0 support` is too broad.
- Reporting recommendation: not ready to file. Need to determine whether this is expected TruffleRuby packaging policy, an Appraisal2 assumption, or an actual bug on supported TruffleRuby. If a supported TruffleRuby cannot respect a lockfile's `BUNDLED WITH` without self-upgrading Bundler, the report should be framed around the concrete command/output rather than "upgrade bundler".
- Priority: medium.

### 6. `stone_checksums` RSpec output matcher skip for TruffleRuby Ruby `3.1..3.2`

- File:
    - `/home/pboling/src/my/galtzo-floss/stone_checksums/spec/gem_checksums/tasks_spec.rb:45`
    - `/home/pboling/src/my/galtzo-floss/stone_checksums/spec/gem_checksums/tasks_spec.rb:95`
- Local classification: spec-only skip, EOL-only.
- Local behavior: skips output matcher examples for `engine: "truffleruby"` and Ruby version range `3.1..3.2`; reason says "output matcher doesn't work here".
- Upstream match: no current issue found for `RSpec output matcher`.
- Reporting recommendation: do not file based on current evidence. Ruby `3.1` and `3.2` are EOL by the Ruby branch support page. Only revisit if this reproduces on TruffleRuby `33.0+` / Ruby `3.3+`.
- Priority: low.

### 7. `kettle-dev` shared skip context for TruffleRuby Ruby `3.1..3.2`

- Files:
    - `/home/pboling/src/my/kettle-dev/kettle-dev/spec/spec_helper.rb:84`
    - `/home/pboling/src/my/kettle-dev/kettle-dev/spec/support/shared_contexts/with_truffleruby_skip_31_32.rb:3`
- Local classification: spec helper, EOL-only.
- Local behavior: provides a shared `skip_for` context for TruffleRuby v23.0/v23.1 mapping to Ruby `3.1..3.2`.
- Upstream match: not searched as a concrete bug because the helper itself does not identify a failing behavior.
- Reporting recommendation: do not file. Treat as legacy compatibility scaffolding unless a specific included example still fails on a supported TruffleRuby.
- Priority: low.

### 8. `kettle-jem` workflow matrix notes and TruffleRuby-specific CI cache branch

- Files:
    - `/home/pboling/src/my/structuredmerge/ruby/gems/kettle-jem/lib/kettle/jem.rb:91`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/kettle-jem/lib/kettle/jem.rb:98`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/kettle-jem/lib/kettle/jem.rb:99`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/kettle-jem/lib/kettle/jem.rb:100`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/kettle-jem/lib/kettle/jem.rb:12843`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/kettle-jem/lib/kettle/jem.rb:12846`
- Local classification: generated CI support / policy encoding, not directly an upstream bug.
- Local behavior:
    - notes repeatedly say not to upgrade RubyGems/Bundler on TruffleRuby.
    - disables `ruby/setup-ruby` bundler cache for `truffleruby-25.0` and runs manual cache setup.
- Upstream match: no specific issue found for the Bundler upgrade/cache behavior.
- Reporting recommendation: not ready to file. This needs a current GitHub Actions repro on supported TruffleRuby showing whether `ruby/setup-ruby` cache or Bundler upgrade fails, and whether the failure belongs to TruffleRuby, `ruby/setup-ruby`, or Bundler.
- Priority: medium-low.

### 9. `tree_haver` native backend capability exclusions

- Files:
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/mri.rb:32`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/mri.rb:64`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/rust.rb:35`
    - `/home/pboling/src/my/structuredmerge/ruby/gems/tree_haver/lib/tree_haver/backends/rust.rb:57`
- Local classification: production capability selection, not a narrow workaround.
- Local behavior:
    - `ruby_tree_sitter` C extension backend only loads on MRI.
    - `tree_stump`/Magnus/Rust backend only loads on MRI.
- Upstream match:
    - Broadly related open issues include:
        - `#3396 Gem commonmarker 1.x fails to compile native extensions with rust`
        - `#1966 ruby_native_statistics: Missing LLVM builtin: llvm.trunc.f64`
    - Neither is a direct `tree_haver`/`tree_stump` match.
- Reporting recommendation: do not file from comments alone. If `tree_stump` install/use fails on supported TruffleRuby, collect a minimal install/runtime repro and compare against #3396 before deciding whether to file a new Magnus/rb-sys issue.
- Priority: low until reproduced.

## Reporting queue after validation

1. Filed `truffleruby/truffleruby#4345` for the direct `FFI::DynamicLibrary.open` missing-library exception class mismatch.
2. No duplicate filing for FFI struct-by-value. Track or comment on `truffleruby/truffleruby#3835` if `tree_haver` evidence would be useful.
3. Do not file for the bundled-gems `File.path(nil)` note from current evidence. Normal parser-gem requires did not reproduce the TypeError on supported TruffleRuby versions tested.
4. Do not file for the Appraisal2 Bundler DSL generation skips from current evidence. The isolated generation repro passes on supported TruffleRuby versions tested.
5. Do not file for the Appraisal2 lockfile/Bundler-version skip from current evidence. The isolated install repro preserved the locked Bundler version on supported TruffleRuby versions tested.
6. Do not report the `stone_checksums` and `kettle-dev` Ruby `3.1..3.2` skips unless they reproduce on Ruby `3.3+` compatibility.

## Validation pass 2026-06-26

Local mini-project repros were added under this repository. They are intentionally
review-only and do not publish upstream issues.

Validated interpreters:

- `truffleruby+graalvm-33.0.1`: `truffleruby 33.0.1 (2026-01-20), like ruby 3.3.7`
- `truffleruby+graalvm-34.0.0`: `truffleruby 34.0.0 (2026-04-10), like ruby 3.4.9`
- CRuby control: `ruby 3.4.8`
- Attempted `truffleruby+graalvm-40.0.0`, but the local `mise`/`ruby-build` plugin did not know that version.

Repros and results:

- `ffi-missing-library/`: current issue on TruffleRuby 33.0.1 and 34.0.0. `FFI::DynamicLibrary.open` on a missing `.so` raises `RuntimeError`, while the CRuby 3.4.8 control raises `LoadError`. Filed upstream as `truffleruby/truffleruby#4345`: https://github.com/truffleruby/truffleruby/issues/4345
- `ffi-struct-by-value/`: known current issue on TruffleRuby 33.0.1 and 34.0.0. Attaching a tiny C function returning a struct by value fails with `Polyglot::ForeignException: unknown simple type 'STRUCT_BY_VALUE'`. CRuby 3.4.8 returns the expected struct values. This remains a duplicate/evidence item for upstream `#3835`, not a new issue.
- `bundled-gems-file-path-nil/`: not reproduced as an active issue on TruffleRuby 33.0.1 or 34.0.0. Normal `require "citrus"` and `require "parslet"` succeed. A direct internal probe of `Gem::BUNDLED_GEMS.warning?(nil)` raises `TypeError` on both TruffleRuby and CRuby, so that direct call is context only and not a reportable normal-require failure.
- `appraisal2-dsl-generation/`: not reproduced as an active issue on TruffleRuby 33.0.1 or 34.0.0. The skipped Bundler DSL generation shape matches expected output; CRuby 3.4.8 control also passes.
- `appraisal2-bundler-lock/`: not reproduced as an active issue on TruffleRuby 33.0.1 or 34.0.0. The repro installs and preserves a decremented locked Bundler version (`4.0.4` from `4.0.5` on 33.0.1; `2.6.8` from `2.6.9` on 34.0.0).

Additional findings from the repro attempts:

- The `ffi-missing-library/` repro was narrowed after checking `ffi_lib` directly. On TruffleRuby 34.0.0, `ffi_lib "/no/such/libmissing.so"` raises `LoadError`, matching CRuby/ffi behavior. The remaining mismatch is specifically direct use of `FFI::DynamicLibrary.open`, which raises `RuntimeError` on TruffleRuby.
- GitHub issue search with `gh` found related but not duplicate issues:
    - `#1926` shows a missing `ffi_lib` library path surfacing as `LoadError`, which supports the narrower direct-API framing for `#4345`.
    - `#1750` contains older debug output where TruffleRuby internally raised `RuntimeError` while probing FFI libraries and later surfaced `LoadError` through `ffi_lib`.
    - `#2769` and `#4044` involve shared-library/linking failures but not the direct `FFI::DynamicLibrary.open` exception-class contract.
- The `bundled-gems-file-path-nil/` repro found that `Gem::BUNDLED_GEMS.warning?(nil)` raises `TypeError` as an internal direct-call probe on both TruffleRuby and CRuby. That means the direct nil probe is not itself a TruffleRuby compatibility bug; only a normal `require` raising this TypeError would be actionable, and that did not reproduce with `citrus` or `parslet`.
- The first `appraisal2-dsl-generation/` attempt produced a mismatch because the simplified fixture used the wrong `install_if` shape. After matching the skipped spec's quoted `install_if '"-> { true }"'` form, TruffleRuby 34.0.0 and CRuby 3.4.8 both produced the expected generated Gemfile.
- The first full-matrix `appraisal2-bundler-lock/` run on TruffleRuby 33.0.1 produced a false negative because the checker expected exact `BUNDLED WITH` indentation. After changing the checker to use a whitespace-tolerant regex, TruffleRuby 33.0.1 passed and preserved Bundler `4.0.4`; TruffleRuby 34.0.0 passed and preserved Bundler `2.6.8`.
- The full `./run_all.sh` matrix exits nonzero by design while `ffi-missing-library/` and `ffi-struct-by-value/` classify active issues. Passing repros print `PASS no active issue`.

Current validated classification:

- Current filed issue: FFI missing shared-library exception shape (`RuntimeError` vs `LoadError`), tracked as `truffleruby/truffleruby#4345`.
- Current known duplicate/evidence only: FFI struct-by-value (`STRUCT_BY_VALUE`, upstream `#3835`).
- Not active in validated supported versions: bundled-gems normal require TypeError, Appraisal2 DSL generation skip, Appraisal2 Bundler lock skip.
- Still not revisited: EOL-only `stone_checksums` and `kettle-dev` skips, plus native extension capability exclusions that were comments/policy rather than concrete failures.

## Current conclusion

There is one confirmed current upstream match: TruffleRuby FFI struct-by-value support (`#3835`). The validation pass also confirmed and filed one current issue: `FFI::DynamicLibrary.open` raises `RuntimeError` instead of `LoadError` for a missing shared library on supported TruffleRuby versions available locally (`#4345`). The bundled-gems TypeError and Appraisal2 skips did not reproduce as active issues in the supported versions tested.

## Validation pass 2026-07-01

Added `bundler-unbundled-env-thread/` for the parallel `kettle-family release`
failure shape. The minimized repro concurrently calls
`Bundler.with_unbundled_env` from four Ruby threads while Bundler environment
variables are present, then yields with `Thread.pass`.

Validated interpreters:

- CRuby control: `ruby 3.4.8`
- `truffleruby+graalvm-33.0.1`: `truffleruby 33.0.1`, Ruby 3.3-compatible line
- `truffleruby+graalvm-34.0.0`: `truffleruby 34.0.0`, Ruby 3.4-compatible line

Results:

- CRuby 3.4.8 passes with `REPRO_THREADS=4 REPRO_ITERATIONS=200`.
- TruffleRuby 33.0.1 fails with an internal JVM error:
  `Null receiver values are not supported by libraries`.
- TruffleRuby 34.0.0 fails with the same internal JVM error.
- The failing stack goes through `Bundler.with_unbundled_env`,
  `Bundler.with_env`, TruffleRuby `core/env.rb`, and array deletion during
  environment replacement.

Issue search:

- No open or closed `truffleruby/truffleruby` issue was found for
  `Bundler.with_unbundled_env`, `core/env.rb` plus `with_unbundled_env`, or
  `ENV.replace` plus threads.
- Exact-message search found older closed issues with the same generic Java
  exception text. The closest is
  `#3447 Java exceptions from CompactHashStore`, but it describes non-thread-safe
  hash internals rather than Bundler environment replacement.

Current classification:

- Current unreported issue candidate: concurrent `Bundler.with_unbundled_env`
  can crash TruffleRuby 33.0.1 and 34.0.0 with an internal
  `Null receiver values are not supported by libraries` JVM error.
- Local mitigation remains appropriate in `kettle-family`: avoid parallel family
  release worker threads on TruffleRuby until upstream behavior is fixed or the
  release runner no longer shares process-wide Bundler environment mutation
  across threads.
