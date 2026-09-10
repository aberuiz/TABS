#' Get registered projects
#'
#' @description
#' Returns a df of projects registered in the TABS database
#'
#' @param county The Texas county where the physical project is
#' @param city The Texas city where the physical project is
#' @param reg_begin The start date for searching projects Date Format: mm/dd/yy
#' @param reg_end The cutoff date for searching projects Date Format: mm/dd/yy
#' @param owner Search by the owner of a project
#' @param project Search by project name
#' @param facility Search by the facility name
#' @param address Search by the physical address of a project
#'
#' @param strict If `TRUE`, error when response completeness cannot be established.
#'   Defaults to `FALSE`, which warns and returns available results.
#' @param request_interval Minimum seconds between search requests in this R
#'   session (including retries). Defaults to 1.5; use 0 to disable pacing.
#' @param timeout Optional timeout in seconds for each HTTP attempt. `NULL`
#'   leaves the existing HTTP timeout behavior unchanged.
#' @param user_agent User-Agent sent to TDLR. May include the caller's contact.
#'
#' @details
#' Use `strict = TRUE` for jobs that checkpoint a search as complete. Validation
#' checks response structure, repeated pages and `recordsFiltered`, but cannot
#' guarantee a snapshot when the database changes during a search. HTTP and
#' JSON parsing errors still propagate in both modes. In permissive mode, an
#' invalid response with no usable rows returns invisible `NULL` with a warning.
#'
#' @returns A data frame of projects matching the given criteria. If no projects
#'   match, returns `NULL` invisibly with a warning.
#'
#' @examples
#' GetProjects(
#'   county = "Caldwell",
#'   reg_begin = "03/01/24",
#'   reg_end = "04/01/24"
#' )
#' GetProjects(
#'   city = "Austin",
#'   owner = "Tesla",
#'   reg_begin = "01/01/20",
#'   reg_end = "01/01/24"
#' )
#' @export
GetProjects <- function(county = NULL, city = NULL, reg_begin = "", reg_end = "", owner = "", project = "", facility = "", address = "",
                        strict = FALSE, request_interval = 1.5, timeout = NULL,
                        user_agent = "TABS R package (https://aberuiz.github.io/TABS/)"){
  if (!is.logical(strict) || length(strict) != 1 || is.na(strict)){
    stop("strict must be TRUE or FALSE", call. = FALSE)
  }
  if (!is.numeric(request_interval) || length(request_interval) != 1 ||
      !is.finite(request_interval) || request_interval < 0){
    stop("request_interval must be a finite, non-negative number", call. = FALSE)
  }
  if (!is.null(timeout) && (!is.numeric(timeout) || length(timeout) != 1 ||
      !is.finite(timeout) || timeout <= 0)){
    stop("timeout must be NULL or a finite, positive number", call. = FALSE)
  }
  if (!is.character(user_agent) || length(user_agent) != 1 ||
      is.na(user_agent) || !nzchar(user_agent)){
    stop("user_agent must be a non-empty string", call. = FALSE)
  }
  incomplete <- function(message) {
    message <- paste0("TABS response completeness could not be established: ", message)
    if (strict) stop(message, call. = FALSE)
    warning(message, call. = FALSE)
  }
  # Decode city &/or county character value to integer for request
  # The TDLR county filter offers the 2000-series counties plus 9999 ("Unknown");
  # the city filter offers the 1-1999 cities plus the same 9999 "Unknown". Restrict
  # each name lookup to its own dropdown's codes so that (a) a name that is both a
  # city and a county (e.g. "Austin") resolves to the intended one, and (b) names
  # never resolve to the 3000-series statuses or 9000-series work types, which are
  # not valid location filters. 9999 is included in both so `"Unknown"` still works.
  if (!is.null(county)){
    countycodes <- subset(codebook, (codebook$code > 1999 & codebook$code < 3000) | codebook$code == 9999)
    county <- TABSdecoder(county, codebook_df = countycodes)
  }

  if (!is.null(city)){
    citycodes <- subset(codebook, codebook$code < 2000 | codebook$code == 9999)
    city <- TABSdecoder(city, codebook_df = citycodes)
  }

  all_data <- list()
  page <- 0
  expected <- NULL
  count_warning <- FALSE
  complete <- FALSE
  seen_pages <- new.env(parent = emptyenv())
  max_pages <- tabs_max_pages()

  request <- httr2::request("https://www.tdlr.texas.gov/TABS/Search/SearchProjects") |>
    httr2::req_headers(
      `Accept` = "application/json",
      `Connection` = "keep-alive"
    ) |>
    httr2::req_user_agent(user_agent) |>
    httr2::req_retry(
      max_tries = 3,
      backoff = function(tries) max(request_interval, stats::runif(1, 1, min(60, 2^tries))),
      after = function(response) tabs_retry_after(response, request_interval)
    )
  if (!is.null(timeout)){
    request <- httr2::req_timeout(request, timeout)
  }

  while (page < max_pages){
    page_request <- httr2::req_body_form(
      request,
      start = page * 100,
      length = 100,
      `search[value]` = "true",
      `search[regex]` = "false",
      RegistrationDateBegin = reg_begin,
      RegistrationDateEnd = reg_end,
      OwnerName = owner,
      ProjectName = project,
      FacilityName = facility,
      LocationAddress = address,
      LocationCity = if (is.null(city)) "" else city,
      LocationCounty = if (is.null(county)) "" else county
    )
    response <- perform_tabs_request(page_request, request_interval)
    if (!is.list(response) || is.null(response[["data"]]) ||
        !is.list(response[["data"]]) || !is.null(names(response[["data"]]))){
      incomplete("missing or invalid data array.")
      break
    }
    rows_valid <- vapply(response[["data"]], function(row) {
      required <- c("ProjectNumber", "ProjectStatus", "City", "County", "TypeOfWork")
      is.list(row) && all(required %in% names(row)) &&
        all(vapply(row[required], function(value) {
          is.atomic(value) && length(value) == 1 && !is.na(value)
        }, logical(1)))
    }, logical(1))
    if (!all(rows_valid)){
      incomplete("invalid project rows.")
      break
    }
    data <- tryCatch(dplyr::bind_rows(response[["data"]]), error = function(e) NULL)
    if (is.null(data)){
      incomplete("project rows could not be combined.")
      break
    }

    count <- response[["recordsFiltered"]]
    valid_count <- is.numeric(count) && length(count) == 1 &&
      is.finite(count) && count >= 0 && count == floor(count)
    if (!valid_count || (!is.null(expected) && count != expected)){
      if (!count_warning){
        incomplete("recordsFiltered is missing, invalid or changed during pagination.")
        count_warning <- TRUE
      }
    } else if (is.null(expected)){
      expected <- count
    }

    if (nrow(data) == 0){
      complete <- TRUE
      break
    }
    # A sorted set of project numbers also catches a repeated page in a new order.
    numbers <- sort(as.character(data$ProjectNumber))
    key <- paste0("page:", paste(nchar(numbers), numbers, sep = ":", collapse = "|"))
    if (exists(key, envir = seen_pages, inherits = FALSE)){
      incomplete("a repeated page was returned; the repeated page was excluded.")
      break
    }
    assign(key, TRUE, envir = seen_pages)
    combined <- tryCatch(dplyr::bind_rows(all_data, data), error = function(e) NULL)
    if (is.null(combined)){
      incomplete("project columns changed between pages.")
      break
    }
    all_data <- combined
    page <- page + 1
  }
  received <- if (is.data.frame(all_data)) nrow(all_data) else 0L
  if (page == max_pages && !(!is.null(expected) && !count_warning && received == expected)){
    incomplete("the pagination safety cap was reached.")
  } else if (complete && !is.null(expected) && received != expected){
    incomplete(paste0("expected ", expected, " rows but received ", received, "."))
  }
  if (received == 0){
    warning("No projects found for the registration period")
    return(invisible(NULL))
  }

  # Decode the coded columns back to plain-language labels. TDLR currently
  # returns these as integers, so TABSdecoder's numeric branch handles them.
  # If TDLR ever returns them as JSON strings, that branch would be skipped and
  # every value would decode to NA; wrap each column in as.integer() here if so.
  all_data[c("ProjectStatus","City","County","TypeOfWork")] <- lapply(
    all_data[c("ProjectStatus","City","County","TypeOfWork")],
    TABSdecoder
  )
  return(all_data)
}

# Keep the network boundary small so GetProjects can be tested with deterministic
# responses without making live requests to TDLR.
perform_tabs_request <- function(request, request_interval = 1.5) {
  # Pause even after a failed request, before a caller can start another search.
  # Retry delays within req_perform() are handled by req_retry() above.
  on.exit(if (request_interval > 0) Sys.sleep(request_interval))
  request |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}

# Kept internal so the safety cap can be exercised without 10,000 requests.
tabs_max_pages <- function() 10000L

# Retry-After takes precedence over httr2's backoff. Apply the pacing floor to
# both paths, including servers asking for an immediate retry.
tabs_retry_after <- function(response, request_interval) {
  seconds <- httr2::resp_retry_after(response)
  if (!is.finite(seconds)) return(NA_real_)
  max(request_interval, seconds)
}
