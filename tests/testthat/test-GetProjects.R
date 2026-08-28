empty_response <- function() {
  list(data = list())
}

project_response <- function() {
  list(data = list(list(
    ProjectNumber = "TABS2026000001",
    ProjectStatus = 3001L,
    City = 77L,
    County = 2028L,
    TypeOfWork = 9001L
  )))
}

test_that("no matches warn and return invisible NULL", {
  local_mocked_bindings(
    perform_tabs_request = function(request) empty_response(),
    .package = "TABS"
  )

  expect_warning(
    result <- withVisible(GetProjects()),
    "No projects found for the registration period"
  )
  expect_null(result$value)
  expect_false(result$visible)
})

test_that("results survive the final empty page and are decoded", {
  responses <- list(project_response(), empty_response())
  page <- 0L
  local_mocked_bindings(
    perform_tabs_request = function(request) {
      page <<- page + 1L
      responses[[page]]
    },
    .package = "TABS"
  )

  result <- GetProjects()

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_equal(page, 2L)
  expect_equal(result$ProjectStatus, "Inspection Complete")
  expect_equal(result$City, "Austin")
  expect_equal(result$County, "Caldwell")
  expect_equal(result$TypeOfWork, "New Construction")
})

test_that("request errors propagate to the caller", {
  local_mocked_bindings(
    perform_tabs_request = function(request) {
      stop("simulated request failure", call. = FALSE)
    },
    .package = "TABS"
  )

  expect_error(GetProjects(), "simulated request failure")
})

test_that("invalid locations error before making a request", {
  request_made <- FALSE
  local_mocked_bindings(
    perform_tabs_request = function(request) {
      request_made <<- TRUE
      empty_response()
    },
    .package = "TABS"
  )

  expect_error(GetProjects(county = "Not A Texas County"), "Not A Texas County")
  expect_false(request_made)
})
