# A small fixture codebook covering the ranges TABSdecoder distinguishes:
# a city (< 2000), a county (2000-series), and the shared 9999 "Unknown".
cb <- data.frame(
  code  = c(77L, 2008L, 2028L, 9999L),
  value = c("Austin", "Austin", "Caldwell", "Unknown"),
  stringsAsFactors = FALSE
)

test_that("numeric codes decode to their labels", {
  expect_equal(TABSdecoder(c(77L, 2028L), cb), c("Austin", "Caldwell"))
  expect_equal(TABSdecoder(9999L, cb), "Unknown")
})

test_that("unknown numeric codes decode to NA rather than erroring", {
  # Result columns may contain a code not yet in the codebook; this must not
  # abort an entire fetch, so the numeric branch returns NA silently.
  expect_equal(TABSdecoder(c(77L, 123456L), cb), c("Austin", NA))
})

test_that("names decode to codes, case- and whitespace-insensitively", {
  expect_equal(TABSdecoder("caldwell", cb), 2028L)
  expect_equal(TABSdecoder("  CALDWELL  ", cb), 2028L)
})

test_that("subsetting the codebook disambiguates city vs county", {
  county_only <- cb[cb$code > 1999 & cb$code < 3000, ]
  city_only   <- cb[cb$code < 2000, ]
  expect_equal(TABSdecoder("Austin", county_only), 2008L)
  expect_equal(TABSdecoder("Austin", city_only), 77L)
})

test_that("unrecognized names raise an informative error", {
  expect_error(TABSdecoder("Nowhere", cb), "Nowhere")
})

test_that("blank and NA name inputs are treated as no filter, not errors", {
  expect_equal(TABSdecoder("", cb), NA_integer_)
  expect_equal(TABSdecoder(NA_character_, cb), NA_integer_)
})

test_that("a codebook missing the required columns errors", {
  expect_error(
    TABSdecoder(1L, data.frame(x = 1, y = 2)),
    "must have columns"
  )
})
