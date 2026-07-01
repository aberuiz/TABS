# TABS 0.1.2

* `TABSdecoder()` — and therefore `GetProjects()` — now matches city and county
  names case-insensitively and ignores surrounding whitespace, so
  capitalization no longer needs to match TDLR exactly.
* Refreshed the codebook from TDLR. County `2062` is now `"De Witt"`
  (previously `"Dewitt"`); note the internal spacing must be matched.
