# bundled-gems-file-path-nil

Validates the `tree_haver` defensive rescue around TruffleRuby bundled-gems
warnings. The historical note says `bundled_gems.rb` can call `File.path(nil)`
during grammar loading.

This repro exercises real `require` calls for parser-style gems and also probes
the internal `Gem::BUNDLED_GEMS.warning?(nil)` behavior for context. A direct
internal `warning?(nil)` `TypeError` is not itself a reportable compatibility
bug; the reportable case would be a normal `require` raising that `TypeError`.
