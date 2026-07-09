# TABS 0.1.3

* Packaging: switched `DESCRIPTION` to the `Authors@R` field and added
  `testthat` as a test dependency.
* `GetProjects()` no longer embeds stray newlines/whitespace in the request
  body sent to TDLR, making the request robust to stricter form parsing.
* `GetProjects()` now resolves `county`/`city` names against only their own
  TDLR dropdown, so a name that is both a city and a county no longer risks the
  wrong match, and `city = "Unknown"` (code 9999) now resolves correctly. Both
  filters still accept `"Unknown"`.

# TABS 0.1.2

* `TABSdecoder()` — and therefore `GetProjects()` — now matches city and county
  names case-insensitively and ignores surrounding whitespace, so
  capitalization no longer needs to match TDLR exactly.
* Refreshed the codebook from TDLR. County `2062` is now `"De Witt"`
  (previously `"Dewitt"`); note the internal spacing must be matched.
