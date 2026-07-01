
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
#> * checking for file ‘/private/var/folders/gh/fbq3g2jj4h9b09knhwdpmxpc0000gn/T/RtmpKW4b0y/remotes10af23cd5d4d4/aberuiz-TABS-d45f62f/DESCRIPTION’ ... OK
#> * preparing ‘TABS’:
#> * checking DESCRIPTION meta-information ... OK
#> * checking for LF line-endings in source and make files and shell scripts
#> * checking for empty or unneeded directories
#> * building ‘TABS_0.1.1.tar.gz’
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
#>    ProjectNumber  FacilityName             City  County TypeOfWork EstimatedCost
#>    <chr>          <chr>                    <chr> <chr>  <chr>              <dbl>
#>  1 TABS2024012784 ATX Kitchen & Supply     Aust… Travis Renovatio…        400000
#>  2 TABS2024012779 FM 973 Retail Center     Manor Travis New Const…       2100000
#>  3 TABS2024012776 Indeed Tower             Aust… Travis Renovatio…       2224150
#>  4 TABS2024012771 South Lamar Place        Aust… Travis Renovatio…        125000
#>  5 TABS2024012741 CROSSROADS Shopping Cen… Aust… Travis Renovatio…        275000
#>  6 TABS2024012738 One Eleven Congress      Aust… Travis Renovatio…       1200000
#>  7 TABS2024012731 Round Rock Crossing      Roun… Travis Renovatio…        350000
#>  8 TABS2024012707 2300 GUADALUPE STREET    Aust… Travis Renovatio…        375000
#>  9 TABS2024012692 Austin Community Colleg… Aust… Travis Renovatio…        100000
#> 10 TABS2024012676 AMD                      Aust… Travis Renovatio…       1000000
#> 11 TABS2024012665 Bee Cave Shopping Center Bee … Travis Renovatio…         90000
#> # ℹ 7 more variables: ProjectStatus <chr>, ProjectId <chr>, ProjectName <chr>,
#> #   ProjectCreatedOn <chr>, DataVersionId <int>, EstimatedStartDate <chr>,
#> #   EstimatedEndDate <chr>
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
#> # A tibble: 47 × 13
#>    ProjectNumber  FacilityName            City   County TypeOfWork EstimatedCost
#>    <chr>          <chr>                   <chr>  <chr>  <chr>              <dbl>
#>  1 TABS2026006064 Tesla                   Austin Travis New Const…        250000
#>  2 TABS2025021701 Tesla Gigafactory       Austin Travis New Const…         50000
#>  3 TABS2025021600 Tesla Gigafactory       Austin Travis New Const…         50000
#>  4 TABS2025020452 Tesla Gigafactory       Austin Travis New Const…         50000
#>  5 TABS2025020451 Tesla Gigafactory       Austin Travis New Const…         50000
#>  6 TABS2025020450 Tesla Gigafactory       Austin Travis New Const…         50000
#>  7 TABS2025020449 Tesla Gigafactory       Austin Travis New Const…         50000
#>  8 TABS2025020448 Tesla Gigafactory       Austin Travis New Const…         50000
#>  9 TABS2025011400 Tesla Gigafactory Texas Austin Travis New Const…         50000
#> 10 TABS2025008524 Tesla                   Austin Travis New Const…        200000
#> # ℹ 37 more rows
#> # ℹ 7 more variables: ProjectStatus <chr>, ProjectId <chr>, ProjectName <chr>,
#> #   ProjectCreatedOn <chr>, DataVersionId <int>, EstimatedStartDate <chr>,
#> #   EstimatedEndDate <chr>
```

### Details

**Registration Dates:**

Dates are required to be in the mm/dd/yy format. For automating dates,
you can use `format(Sys.Date(), "%D")`. Date arguments are passed to the
database as midnight therefore, `reg_begin` at 02/29/24 will include
projects starting on February 29, 2024 and `reg_end` at 03/01/24 will
mean projects that started on 03/01/24 or later will not be included.

**Name Matching**

City and county names are matched case-insensitively, and surrounding
whitespace is ignored, so capitalization no longer needs to match.
Spelling and internal spacing must still match how TDLR lists the name
(for example, `"De Witt"`, not `"Dewitt"`).
