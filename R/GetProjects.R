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
#' @returns Projects based on the given criteria
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
  if (!is.null(county)){
    countycodes <- subset(dat, dat$code > 1999)
    county <- TABSdecoder(county, codebook_df = countycodes)
  }

  if (!is.null(city)){
    citycodes <- subset(dat, dat$code < 2000)
    city <- TABSdecoder(city, codebook_df = citycodes)
  }

  all_data <- list()
  page <- 0

  while(TRUE){
    response <- httr2::request("https://www.tdlr.texas.gov/TABS/Search/SearchProjects") |>
      httr2::req_headers(
        `Accept` = "application/json",
        `Connection` = "keep-alive"
      ) |>
      httr2::req_body_raw(
        body = paste0("&start=", page * 100,
                      "&length=100
                      &search%5Bvalue%5D=true
                      &search%5Bregex%5D=false",
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
  if (length(all_data) == 0){
    warning("No projects found for the registration period")
  } else {
    all_data[c("ProjectStatus","City","County","TypeOfWork")] <- lapply(
      all_data[c("ProjectStatus","City","County","TypeOfWork")],
      TABSdecoder
    )
    return(all_data)
  }
#  return(all_data)
}
