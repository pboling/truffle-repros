# truffle-repros

Run the available supported-version matrix:

```bash
./run_all.sh
```

The runner currently uses:

- `truffleruby+graalvm-33.0.1`
- `truffleruby+graalvm-34.0.0`

`truffleruby+graalvm-40.0.0` was attempted but was not available through the
local `mise`/`ruby-build` plugin at the time of setup.

Mini-projects:

- `ffi-missing-library/`: missing shared library exception class: https://github.com/truffleruby/truffleruby/issues/4345
- `ffi-struct-by-value/`: known FFI struct-by-value limitation: https://github.com/truffleruby/truffleruby/issues/3835
- `bundled-gems-file-path-nil/`: bundled-gems `File.path(nil)` require probe: only affects EOL-truffles
- `appraisal2-dsl-generation/`: Appraisal2 Bundler DSL generation skip: only affects EOL-truffles
- `appraisal2-bundler-lock/`: Appraisal2 locked Bundler version skip: only affects EOL-truffles

See [status.md](status.md) for classifications and latest validated results.
