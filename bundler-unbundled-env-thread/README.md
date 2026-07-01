# bundler-unbundled-env-thread

Exercises `Bundler.with_unbundled_env` from multiple Ruby threads.
`kettle-family` hit a TruffleRuby 24.2 internal error in this shape during
parallel release specs:

```text
Null receiver values are not supported by libraries.
...
<internal:core> core/env.rb:90:in `delete'
<internal:core> core/env.rb:262:in `block in replace'
... bundler.rb:691:in `with_env'
... bundler.rb:413:in `with_unbundled_env'
```

Expected behavior:

- MRI completes all worker threads.
- TruffleRuby should either complete or raise a normal Ruby exception.
- A JVM/internal TruffleRuby error is the reportable bug.

Validated locally on 2026-07-01:

- CRuby 3.4.8: passes with `REPRO_THREADS=4 REPRO_ITERATIONS=200`.
- TruffleRuby 33.0.1: fails with an internal JVM error.
- TruffleRuby 34.0.0: fails with an internal JVM error.

GitHub issue search found older closed issues with the same generic Java
message, including `truffleruby/truffleruby#3447`, but no open or closed issue
matching the Bundler/ENV call path.

Filed upstream as `truffleruby/truffleruby#4352`:
https://github.com/truffleruby/truffleruby/issues/4352
