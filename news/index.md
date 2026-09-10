# Changelog

## TABS 0.1.5

- [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  now warns when response completeness cannot be established and returns
  available results by default. New `strict = TRUE` raises errors
  instead, for callers that must not checkpoint incomplete searches.
  Checks cover malformed responses, repeated pages,
  missing/invalid/changing `recordsFiltered`, row-count mismatches, and
  the pagination safety cap. Repeated pages are excluded before
  returning results.
- Search requests are paced at least 1.5 seconds apart within an R
  session, including retries. Set `request_interval = 0` to disable
  pacing. Separate R processes do not share the pacing limit.
- Added opt-in per-attempt `timeout` (seconds; default `NULL`) and
  configurable `user_agent`, retaining the existing User-Agent by
  default.
- Search form fields are now encoded correctly, including `&` and `+` in
  names and addresses.
- Existing positional arguments and successful result columns are
  unchanged. Valid empty searches still warn and return invisible
  `NULL`; HTTP and JSON parsing errors still propagate. New completeness
  warnings can become errors for callers using `options(warn = 2)`.

## TABS 0.1.4

- When no projects match,
  [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  now returns `NULL` invisibly (with the existing warning) instead of
  returning the warning message string.
- Added regression tests for empty and paginated
  [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  responses.

## TABS 0.1.3

- Packaging: switched `DESCRIPTION` to the `Authors@R` field and added
  `testthat` as a test dependency.
- [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  no longer embeds stray newlines/whitespace in the request body sent to
  TDLR, making the request robust to stricter form parsing.
- [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  now resolves `county`/`city` names against only their own TDLR
  dropdown, so a name that is both a city and a county no longer risks
  the wrong match, and `city = "Unknown"` (code 9999) now resolves
  correctly. Both filters still accept `"Unknown"`.
- An unrecognized `county`/`city` name now raises an informative error
  *before* any request is made, instead of silently sending `NA` to TDLR
  and returning no results. Blank values (no filter) are still allowed.
- [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  now retries transient network/server failures and identifies itself
  with a descriptive user-agent, and its paging loop has a safety cap so
  it can never loop forever if the server misbehaves.
- Added a `testthat` test suite covering
  [`TABSdecoder()`](https://aberuiz.github.io/TABS/reference/TABSdecoder.md).

## TABS 0.1.2

- [`TABSdecoder()`](https://aberuiz.github.io/TABS/reference/TABSdecoder.md)
  — and therefore
  [`GetProjects()`](https://aberuiz.github.io/TABS/reference/GetProjects.md)
  — now matches city and county names case-insensitively and ignores
  surrounding whitespace, so capitalization no longer needs to match
  TDLR exactly.
- Refreshed the codebook from TDLR. County `2062` is now `"De Witt"`
  (previously `"Dewitt"`); note the internal spacing must be matched.
