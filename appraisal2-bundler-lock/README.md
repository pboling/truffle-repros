# appraisal2-bundler-lock

Validates the Appraisal2 skip that says Bundler version switching is not viable
on TruffleRuby.

The repro creates an appraisal Gemfile lockfile whose `BUNDLED WITH` version is
one patch level below the active Bundler, then asks Appraisal2 to install that
appraisal. A failure to install or invoke that locked Bundler version is a
current issue candidate, but it may belong to TruffleRuby packaging, Bundler, or
Appraisal2 rather than TruffleRuby core.
