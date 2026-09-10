empty_response <- function(records_filtered = 0) {
  list(data = list(), recordsFiltered = records_filtered)
}

project_row <- function(number = "TABS2026000001") {
  list(
    ProjectNumber = number,
    ProjectStatus = 3001L,
    City = 77L,
    County = 2028L,
    TypeOfWork = 9001L
  )
}

project_response <- function(records_filtered = 1, rows = list(project_row())) {
  list(data = rows, recordsFiltered = records_filtered)
}

test_that("no matches warn and return invisible NULL", {
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) empty_response(),
    .package = "TABS"
  )

  expect_warning(
    result <- withVisible(GetProjects(request_interval = 0)),
    "No projects found for the registration period"
  )
  expect_null(result$value)
  expect_false(result$visible)
})

test_that("a strict search accepts a genuine empty response", {
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) empty_response(),
    .package = "TABS"
  )

  expect_warning(
    result <- withVisible(GetProjects(strict = TRUE, request_interval = 0)),
    "No projects found for the registration period"
  )
  expect_null(result$value)
  expect_false(result$visible)
})

test_that("results survive the final empty page and are decoded", {
  responses <- list(project_response(), empty_response(1))
  page <- 0L
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) {
      page <<- page + 1L
      responses[[page]]
    },
    .package = "TABS"
  )

  result <- GetProjects(request_interval = 0)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1L)
  expect_equal(page, 2L)
  expect_equal(result$ProjectStatus, "Inspection Complete")
  expect_equal(result$City, "Austin")
  expect_equal(result$County, "Caldwell")
  expect_equal(result$TypeOfWork, "New Construction")
})

test_that("malformed responses warn permissively and error strictly", {
  responses <- list(project_response(), list(recordsFiltered = 1))
  page <- 0L
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) {
      page <<- page + 1L
      responses[[page]]
    },
    .package = "TABS"
  )

  expect_warning(
    result <- withVisible(GetProjects(request_interval = 0)),
    "missing or invalid data array"
  )
  expect_equal(nrow(result$value), 1L)
  page <- 0L
  expect_error(
    GetProjects(strict = TRUE, request_interval = 0),
    "missing or invalid data array"
  )
})

test_that("repeated pages are excluded even when their rows are reordered", {
  rows <- list(project_row("TABS2026000001"), project_row("TABS2026000002"))
  responses <- list(project_response(2, rows), project_response(2, rev(rows)))
  page <- 0L
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) {
      page <<- page + 1L
      responses[[page]]
    },
    .package = "TABS"
  )

  expect_warning(
    result <- GetProjects(request_interval = 0),
    "repeated page"
  )
  expect_equal(nrow(result), 2L)
  expect_equal(page, 2L)
})

test_that("strict searches fail on repeated pages", {
  response <- project_response(1)
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) response,
    .package = "TABS"
  )

  expect_error(
    GetProjects(strict = TRUE, request_interval = 0),
    "repeated page"
  )
})

test_that("recordsFiltered problems warn permissively", {
  cases <- list(
    list(project_response(records_filtered = NULL), empty_response(NULL)),
    list(project_response(-1), empty_response(-1)),
    list(project_response("1"), empty_response("1")),
    list(project_response(Inf), empty_response(Inf)),
    list(project_response(1), empty_response(2)),
    list(project_response(2), empty_response(2))
  )

  for (responses in cases) {
    page <- 0L
    local_mocked_bindings(
      perform_tabs_request = function(request, ...) {
        page <<- page + 1L
        responses[[page]]
      },
      .package = "TABS"
    )
    expect_warning(
      result <- GetProjects(request_interval = 0),
      "recordsFiltered|expected 2 rows"
    )
    expect_equal(nrow(result), 1L)
  }
})

test_that("strict searches fail on invalid or inconsistent counts", {
  cases <- list(
    list(project_response(records_filtered = NULL), empty_response(NULL)),
    list(project_response(-1), empty_response(-1)),
    list(project_response("1"), empty_response("1")),
    list(project_response(Inf), empty_response(Inf)),
    list(project_response(1), empty_response(2)),
    list(project_response(2), empty_response(2))
  )

  for (responses in cases) {
    page <- 0L
    local_mocked_bindings(
      perform_tabs_request = function(request, ...) {
        page <<- page + 1L
        responses[[page]]
      },
      .package = "TABS"
    )
    expect_error(
      GetProjects(strict = TRUE, request_interval = 0),
      "recordsFiltered|expected 2 rows"
    )
  }
})

test_that("the pagination cap warns or errors before partial results escape", {
  local_mocked_bindings(
    tabs_max_pages = function() 1L,
    perform_tabs_request = function(request, ...) project_response(2),
    .package = "TABS"
  )

  expect_warning(
    result <- GetProjects(request_interval = 0),
    "pagination safety cap"
  )
  expect_equal(nrow(result), 1L)
  expect_error(
    GetProjects(strict = TRUE, request_interval = 0),
    "pagination safety cap"
  )
})

test_that("the pagination cap accepts an exact expected row count", {
  local_mocked_bindings(
    tabs_max_pages = function() 1L,
    perform_tabs_request = function(request, ...) project_response(1),
    .package = "TABS"
  )

  result <- GetProjects(strict = TRUE, request_interval = 0)

  expect_equal(nrow(result), 1L)
})

test_that("request controls encode form values and configure the request", {
  requests <- list()
  intervals <- numeric()
  local_mocked_bindings(
    perform_tabs_request = function(request, request_interval) {
      requests[[length(requests) + 1L]] <<- request
      intervals <<- c(intervals, request_interval)
      empty_response()
    },
    .package = "TABS"
  )

  expect_warning(
    GetProjects(
      owner = "A&B + C", request_interval = 2, timeout = 12,
      user_agent = "contact@example.com"
    ),
    "No projects found"
  )
  request <- requests[[1]]
  expect_equal(as.character(request$body$data$OwnerName), "A%26B%20%2B%20C")
  expect_equal(request$options$useragent, "contact@example.com")
  expect_equal(request$options$timeout_ms, 12000)
  expect_equal(intervals, 2)
})

test_that("invalid request controls error before making a request", {
  request_made <- FALSE
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) {
      request_made <<- TRUE
      empty_response()
    },
    .package = "TABS"
  )

  expect_error(GetProjects(strict = NA, request_interval = 0), "strict")
  expect_error(GetProjects(request_interval = -1), "request_interval")
  expect_error(GetProjects(request_interval = Inf), "request_interval")
  expect_error(GetProjects(timeout = 0), "timeout")
  expect_error(GetProjects(timeout = Inf), "timeout")
  expect_error(GetProjects(user_agent = ""), "user_agent")
  expect_false(request_made)
})

test_that("request errors propagate to the caller", {
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) {
      stop("simulated request failure", call. = FALSE)
    },
    .package = "TABS"
  )

  expect_error(GetProjects(request_interval = 0), "simulated request failure")
})

test_that("invalid locations error before making a request", {
  request_made <- FALSE
  local_mocked_bindings(
    perform_tabs_request = function(request, ...) {
      request_made <<- TRUE
      empty_response()
    },
    .package = "TABS"
  )

  expect_error(GetProjects(county = "Not A Texas County", request_interval = 0), "Not A Texas County")
  expect_false(request_made)
})

test_that("retry delays respect pacing and Retry-After", {
  response <- httr2::response(503, headers = list(`Retry-After` = "0"))
  expect_equal(tabs_retry_after(response, 1.5), 1.5)
  response <- httr2::response(503, headers = list(`Retry-After` = "10"))
  expect_equal(tabs_retry_after(response, 1.5), 10)
  response <- httr2::response(503, headers = list(
    Date = "Tue, 01 Sep 2026 00:00:00 GMT",
    `Retry-After` = "Tue, 01 Sep 2026 00:00:10 GMT"
  ))
  expect_equal(tabs_retry_after(response, 1.5), 10)
  expect_true(is.na(tabs_retry_after(httr2::response(503), 1.5)))

  local_mocked_bindings(
    perform_tabs_request = function(request, ...) {
      expect_gte(request$policies$retry_backoff(1), 10)
      empty_response()
    },
    .package = "TABS"
  )
  expect_warning(GetProjects(request_interval = 10), "No projects found")
})

test_that("the network boundary pauses after success and failure", {
  # Replace sleep in a local copy to check pacing without real waits.
  delays <- numeric()
  perform <- perform_tabs_request
  environment(perform) <- list2env(list(Sys.sleep = function(seconds) {
    delays <<- c(delays, seconds)
  }), parent = environment(perform_tabs_request))
  fail <- FALSE
  local_mocked_bindings(
    req_perform = function(request) {
      if (fail) stop("request failed")
      httr2::response(200, headers = list(`Content-Type` = "application/json"),
                      body = charToRaw('{"data":[],"recordsFiltered":0}'))
    },
    .package = "httr2"
  )

  expect_equal(perform(httr2::request("https://example.com"), 2)$recordsFiltered, 0)
  expect_equal(delays, 2)
  fail <- TRUE
  expect_error(perform(httr2::request("https://example.com"), 3), "request failed")
  expect_equal(delays, c(2, 3))
  expect_error(perform(httr2::request("https://example.com"), 0), "request failed")
  expect_equal(delays, c(2, 3))
})
