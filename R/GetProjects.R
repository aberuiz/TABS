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
GetProjects <- function(county = NULL, city = NULL, reg_begin = "", reg_end = "", owner = "", project = "", facility = "", address = ""){
  # Registration date format must be in mm/dd/yy %D
  reg_beg_formatted <- gsub("/","%2F",reg_begin)
  reg_end_formatted <- gsub("/","%2F",reg_end)
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
  # Paging stops when TDLR returns an empty page. The cap is a safety net: if the
  # server ever ignored `start` and kept returning the first page, the loop would
  # otherwise run forever. 100 rows/page * 10000 pages = far beyond any real result set.
  max_pages <- 10000

  while (page < max_pages){
    response <- httr2::request("https://www.tdlr.texas.gov/TABS/Search/SearchProjects") |>
      httr2::req_headers(
        `Accept` = "application/json",
        `Connection` = "keep-alive"
      ) |>
      httr2::req_user_agent("TABS R package (https://aberuiz.github.io/TABS/)") |>
      # Retry transient network/5xx failures with exponential backoff instead of
      # erroring out on the first hiccup during what may be many paged requests.
      httr2::req_retry(max_tries = 3) |>
      httr2::req_body_raw(
        # Build the form body as one flat string. Writing this as a multi-line
        # literal would embed the source newlines and indentation *inside* the
        # request (e.g. `length=100\n            &search...`), so keep each
        # "&name=value" pair on its own concatenated argument.
        body = paste0("start=", page * 100,
                      "&length=100",
                      "&search%5Bvalue%5D=true",
                      "&search%5Bregex%5D=false",
                      "&RegistrationDateBegin=",reg_beg_formatted,
                      "&RegistrationDateEnd=",reg_end_formatted,
                      "&OwnerName=",owner,
                      "&ProjectName=",project,
                      "&FacilityName=",facility,
                      "&LocationAddress=",address,
                      "&LocationCity=",city,
                      "&LocationCounty=",county),
        "application/x-www-form-urlencoded; charset=UTF-8"
      ) |>
      httr2::req_perform() |>
      httr2::resp_body_json()
    data <- dplyr::bind_rows(response$data)

    if (nrow(data) == 0){
      break
    }
    all_data <- dplyr::bind_rows(all_data, data)
    page <- page + 1
  }
  # `all_data` is either the empty list() seed (no page returned any rows) or a
  # data frame of results. Use is.data.frame()/nrow() rather than length(), which
  # on a data frame reports the column count, not the row count.
  if (!is.data.frame(all_data) || nrow(all_data) == 0){
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
