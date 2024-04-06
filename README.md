
# TABS: An R Package

This package provides an easier way to import project data from the
Texas Architectural Barriers System database maintained by the [Texas
Department of Licensing and Registration](https://www.tdlr.texas.gov/).

### Installation

You can install the development version of TABS from
[GitHub](https:://github.com/aberuiz/TABS) with:

``` r
#install.packages("remotes")
remotes::install_github("aberuiz/TABS")
library(TABS)
```

## Usage

The package works primarily around one function to receive projects
registered with TABS: `GetProjects`.

The example below will pull all projects registered within Travis County
on February 29, 2024.

``` r
GetProjects(
  county = "Travis",
  reg_begin = "02/29/24",
  reg_end = "03/01/24"
)
#> # A tibble: 11 × 13
#>    ProjectId            ProjectNumber ProjectName ProjectCreatedOn ProjectStatus
#>    <chr>                <chr>         <chr>       <chr>            <chr>        
#>  1 49d1f868-09e6-46aa-… TABS20240127… ATX Kitche… 2024-02-29T22:0… Project Regi…
#>  2 862b0820-4e65-4cfa-… TABS20240127… FM 973 Ret… 2024-02-29T20:5… Review Compl…
#>  3 930be231-ddcb-40a4-… TABS20240127… Orrick      2024-02-29T20:0… Review Compl…
#>  4 c6483eaa-317d-40cb-… TABS20240127… South Lama… 2024-02-29T17:1… Project Regi…
#>  5 002ed414-d948-4528-… TABS20240127… La Carnice… 2024-02-29T14:4… Project Regi…
#>  6 f2af9e71-ddd5-4e25-… TABS20240127… ACVB        2024-02-29T14:3… Project Regi…
#>  7 119d43a6-943a-43a0-… TABS20240127… Play Stree… 2024-02-29T13:4… Project Regi…
#>  8 43cfd9f8-6aca-450c-… TABS20240127… DOLLAR SLI… 2024-02-29T11:0… Review Compl…
#>  9 a66721a4-a85b-4738-… TABS20240126… UFCU ACC H… 2024-02-29T10:2… Review Compl…
#> 10 5b3a70b9-6186-4c61-… TABS20240126… AMD B200 -… 2024-02-29T09:1… Project Regi…
#> 11 48fc131a-930b-4331-… TABS20240126… Vital Stre… 2024-02-29T06:2… Project Regi…
#> # ℹ 8 more variables: FacilityName <chr>, City <chr>, County <chr>,
#> #   TypeOfWork <chr>, EstimatedCost <dbl>, DataVersionId <int>,
#> #   EstimatedStartDate <chr>, EstimatedEndDate <chr>
```

## Additional Arguments

In addition to dates you can search for projects by county, city,
address, owner name, facility, and/or project name. The below example
will search for all projects in the City of Austin that are owned by
Tesla.

``` r
GetProjects(
  city = "Austin",
  owner = "Tesla"
)
#> # A tibble: 18 × 13
#>    ProjectId            ProjectNumber ProjectName ProjectCreatedOn ProjectStatus
#>    <chr>                <chr>         <chr>       <chr>            <chr>        
#>  1 5e9807b6-2e19-4321-… TABS20240050… Tesla - Au… 2023-11-09T16:2… Review Compl…
#>  2 10bfef25-1f11-4d69-… TABS20240050… Tesla - Au… 2023-11-09T15:5… Review Compl…
#>  3 cb51ea73-45d2-42e9-… TABS20240050… Tesla - Au… 2023-11-09T15:2… Review Compl…
#>  4 f4fe51eb-f383-49a4-… TABS20240016… Tesla - CY… 2023-09-25T15:2… Review Compl…
#>  5 73e58c62-18a8-4cc5-… TABS20240015… Tesla - Au… 2023-09-22T11:3… Project Regi…
#>  6 1a606421-df95-45f2-… TABS20230224… Tesla - Au… 2023-06-28T13:3… Review Compl…
#>  7 6eeb5963-58b7-41b6-… TABS20230145… Tesla - Au… 2023-03-21T08:4… Review Compl…
#>  8 cb1db4ea-f42d-4246-… TABS20230090… Tesla Inc.  2023-01-10T15:1… Review Compl…
#>  9 e85eb537-95c8-407e-… TABS20230089… Tesla Inc.  2023-01-09T15:5… Review Compl…
#> 10 73e05b7b-333a-4fca-… TABS20230089… Tesla Inc.  2023-01-09T15:4… Review Compl…
#> 11 b45fdc21-7e8f-41a5-… TABS20230089… Tesla Inc.  2023-01-09T13:2… Review Compl…
#> 12 c3942697-0d34-4ff2-… TABS20230089… Tesla Inc.  2023-01-09T13:0… Review Compl…
#> 13 78770e35-799a-4bec-… TABS20230079… Tesla Inc.  2022-12-20T10:0… Review Compl…
#> 14 f231061e-6e6a-4e0b-… TABS20220057… Tesla Inc.  2021-11-19T19:2… Review Compl…
#> 15 b2ceedb5-f47c-412c-… TABS20220057… Tesla Inc.  2021-11-19T19:1… Review Compl…
#> 16 b0acf81d-bf5e-495b-… TABS20220057… Tesla Inc.  2021-11-19T19:0… Review Compl…
#> 17 c0d2c11c-73ee-47c0-… TABS20220057… Tesla Inc.  2021-11-19T18:5… Review Compl…
#> 18 e1b5be59-bc3a-4fc5-… TABS20220057… Tesla Inc.  2021-11-19T18:4… Review Compl…
#> # ℹ 8 more variables: FacilityName <chr>, City <chr>, County <chr>,
#> #   TypeOfWork <chr>, EstimatedCost <dbl>, DataVersionId <int>,
#> #   EstimatedStartDate <chr>, EstimatedEndDate <chr>
```

### Details

**Registration Dates:**

Dates are required to be in the mm/dd/yy format. For automating dates,
you can use `format(Sys.Date(), "%D")`. Date arguments are passed to the
database as midnight therefore, `reg_begin` at 02/29/24 will include
projects starting on February 29, 2024 and `reg_end` at 03/01/24 will
mean projects that started on 03/01/24 or later will not be included.

**Capitalization**

As of this version, city and county names must follow appropriate
capitalization rules.
