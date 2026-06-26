# ffi-missing-library

Validates the `tree_haver` workaround that rescues `RuntimeError` in addition to
`LoadError` when `FFI::DynamicLibrary.open` cannot open a shared library.

Upstream issue:

- https://github.com/truffleruby/truffleruby/issues/4345

Classification:

- `LoadError`: no current TruffleRuby issue for this behavior.
- `RuntimeError`: current TruffleRuby exception-shape issue tracked as
  `truffleruby/truffleruby#4345`.
