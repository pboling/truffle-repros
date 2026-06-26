# ffi-missing-library

Validates the `tree_haver` workaround that rescues `RuntimeError` in addition to
`LoadError` when `FFI::DynamicLibrary.open` cannot open a shared library.

Classification:

- `LoadError`: no current TruffleRuby issue for this behavior.
- `RuntimeError`: current TruffleRuby or TruffleRuby/ffi exception-shape issue.
