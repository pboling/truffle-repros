# ffi-struct-by-value

Confirms the known `tree_haver` FFI backend limitation: tree-sitter APIs return
structs by value, and TruffleRuby currently tracks that under upstream issue
`truffleruby/truffleruby#3835`.

This repro compiles a tiny C shared library inside the project-local `tmp/`
directory and calls a function returning a struct by value through Ruby FFI.
