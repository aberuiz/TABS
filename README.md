
# TABS: An R Package

This package provides an easier way to import project data from the
Texas Architectural Barriers System database maintained by the [Texas
Department of Licensing and Regulation](https://www.tdlr.texas.gov/).

### Installation

You can install the development version of TABS from
[GitHub](https:://github.com/aberuiz/TABS) with:

``` r
#install.packages("remotes")
remotes::install_github("aberuiz/TABS")
#> 
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>      checking for file ‘/private/var/folders/gh/fbq3g2jj4h9b09knhwdpmxpc0000gn/T/RtmpVipEQs/remotes9b2a422e504c/aberuiz-TABS-44892e6/DESCRIPTION’ ...  ✔  checking for file ‘/private/var/folders/gh/fbq3g2jj4h9b09knhwdpmxpc0000gn/T/RtmpVipEQs/remotes9b2a422e504c/aberuiz-TABS-44892e6/DESCRIPTION’
#>   ─  preparing ‘TABS’:
#>      checking DESCRIPTION meta-information ...  ✔  checking DESCRIPTION meta-information
#>   ─  checking for LF line-endings in source and make files and shell scripts
#>   ─  checking for empty or unneeded directories
#>        NB: this package now depends on R (>= 4.1.0)
#>        WARNING: Added dependency on R >= 4.1.0 because package code uses the
#>      pipe |> or function shorthand \(...) syntax added in R 4.1.0.
#>      File(s) using such syntax:
#>        ‘GetProjects.R’
#>   ─  building ‘TABS_0.1.0.tar.gz’
#>      
#> 
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
#>  1 49d1f868-09e6-46aa-… TABS20240127… ATX Kitche… 2024-02-29T22:0… Inspection C…
#>  2 862b0820-4e65-4cfa-… TABS20240127… FM 973 Ret… 2024-02-29T20:5… Review Compl…
#>  3 930be231-ddcb-40a4-… TABS20240127… Orrick      2024-02-29T20:0… Project Clos…
#>  4 c6483eaa-317d-40cb-… TABS20240127… South Lama… 2024-02-29T17:1… Review Compl…
#>  5 002ed414-d948-4528-… TABS20240127… La Carnice… 2024-02-29T14:4… Review Compl…
#>  6 f2af9e71-ddd5-4e25-… TABS20240127… ACVB        2024-02-29T14:3… Project Clos…
#>  7 119d43a6-943a-43a0-… TABS20240127… Play Stree… 2024-02-29T13:4… Project Regi…
#>  8 43cfd9f8-6aca-450c-… TABS20240127… DOLLAR SLI… 2024-02-29T11:0… Project Clos…
#>  9 a66721a4-a85b-4738-… TABS20240126… UFCU ACC H… 2024-02-29T10:2… Project Clos…
#> 10 5b3a70b9-6186-4c61-… TABS20240126… AMD B200 -… 2024-02-29T09:1… Review Compl…
#> 11 48fc131a-930b-4331-… TABS20240126… Vital Stre… 2024-02-29T06:2… Project Clos…
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
#> # A tibble: 46 × 13
#>    ProjectId            ProjectNumber ProjectName ProjectCreatedOn ProjectStatus
#>    <chr>                <chr>         <chr>       <chr>            <chr>        
#>  1 2204d890-e4df-4414-… TABS20250217… Visitor Ci… 2025-06-20T07:2… Review Compl…
#>  2 d9b4c252-d7c4-4b36-… TABS20250216… Employee a… 2025-06-18T16:4… Review Compl…
#>  3 6430d938-860c-4e55-… TABS20250204… GAX PS      2025-06-04T07:3… Project Clos…
#>  4 22527b2b-0091-4784-… TABS20250204… GA PS       2025-06-04T07:3… Review Compl…
#>  5 bc6e75ff-e12c-4310-… TABS20250204… DU PS       2025-06-04T07:2… Review Compl…
#>  6 9833e924-929c-45aa-… TABS20250204… ST2 Office  2025-06-04T07:2… Review Compl…
#>  7 b4c97f71-8388-4976-… TABS20250204… ST1 Breakr… 2025-06-04T07:2… Review Compl…
#>  8 435d677f-c3f0-489b-… TABS20250114… HGR         2025-02-07T14:2… Review Compl…
#>  9 f87daa44-7c65-4377-… TABS20250085… Tesla - Au… 2024-12-27T15:1… Review Compl…
#> 10 ecdc154a-ad93-4bf4-… TABS20250043… GA Lobby    2024-10-29T06:5… Project Clos…
#> # ℹ 36 more rows
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
