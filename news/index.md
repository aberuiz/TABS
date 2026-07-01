# Changelog

## TABS 0.1.2

- [`TABSdecoder()`](https://aberuiz.github.io/TABS/reference/TABSdecoder.md)
  — and therefore
  [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  — now matches city and county names case-insensitively and ignores
  surrounding whitespace, so capitalization no longer needs to match
  TDLR exactly.
- Refreshed the codebook from TDLR. County `2062` is now `"De Witt"`
  (previously `"Dewitt"`); note the internal spacing must be matched.
