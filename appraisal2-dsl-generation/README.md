# appraisal2-dsl-generation

Validates the broad TruffleRuby skips in Appraisal2 Bundler DSL generation specs
without running the full acceptance harness.

The repro loads Appraisal2 from the sibling checkout, writes temporary Gemfile
and Appraisals inputs, runs the same generation API used by `appraisal generate`,
and compares generated Gemfile text for the skipped DSL cases.
