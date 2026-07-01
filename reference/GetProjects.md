# Get registered projects

Returns a df of projects registered in the TABS database

## Usage

``` r
GetProjects(
  county = NULL,
  city = NULL,
  reg_begin = "",
  reg_end = "",
  owner = "",
  project = "",
  facility = "",
  address = ""
)
```

## Arguments

- county:

  The Texas county where the physical project is

- city:

  The Texas city where the physical project is

- reg_begin:

  The start date for searching projects Date Format: mm/dd/yy

- reg_end:

  The cutoff date for searching projects Date Format: mm/dd/yy

- owner:

  Search by the owner of a project

- project:

  Search by project name

- facility:

  Search by the facility name

- address:

  Search by the physical address of a project

## Value

Projects based on the given criteria

## Examples

``` r
GetProjects(
  county = "Caldwell",
  reg_begin = "03/01/24",
  reg_end = "04/01/24"
)
#> # A tibble: 2 × 13
#>   ProjectNumber FacilityName City  County TypeOfWork EstimatedCost ProjectStatus
#>   <chr>         <chr>        <chr> <chr>  <chr>              <dbl> <chr>        
#> 1 TABS20240143… City of Loc… Lock… Caldw… Renovatio…        878720 Review Compl…
#> 2 TABS20240138… Main Church… Dale  Caldw… New Const…        225000 Review Compl…
#> # ℹ 6 more variables: ProjectId <chr>, ProjectName <chr>,
#> #   ProjectCreatedOn <chr>, DataVersionId <int>, EstimatedStartDate <chr>,
#> #   EstimatedEndDate <chr>
GetProjects(
  city = "Austin",
  owner = "Tesla",
  reg_begin = "01/01/20",
  reg_end = "01/01/24"
)
#> # A tibble: 18 × 13
#>    ProjectNumber  FacilityName        City   County TypeOfWork     EstimatedCost
#>    <chr>          <chr>               <chr>  <chr>  <chr>                  <dbl>
#>  1 TABS2024005095 "Tesla"             Austin Travis New Construct…        180000
#>  2 TABS2024005089 "Tesla"             Austin Travis New Construct…        170000
#>  3 TABS2024005082 "Tesla"             Austin Travis New Construct…        170000
#>  4 TABS2024001696 "Shop: GAX"         Austin Travis Renovation/Al…      10500000
#>  5 TABS2024001561 "Tesla"             Austin Travis New Construct…        180000
#>  6 TABS2023022484 "Tesla"             Austin Travis New Construct…        170000
#>  7 TABS2023014558 "Tesla, Inc."       Austin Travis New Construct…        140000
#>  8 TABS2023009082 "Die Shop"          Austin Travis New Construct…      59000000
#>  9 TABS2023008989 "Cell 1"            Austin Travis New Construct…     368000000
#> 10 TABS2023008982 "Drive Unit"        Austin Travis New Construct…      85000000
#> 11 TABS2023008949 "Cathode"           Austin Travis New Construct…     260000000
#> 12 TABS2023008944 "Cell Test Lab"     Austin Travis New Construct…       3700000
#> 13 TABS2023007945 "Plastics"          Austin Travis New Construct…      58000000
#> 14 TABS2022005792 "Body in White"     Austin Travis New Construct…     182000000
#> 15 TABS2022005791 "Stamping "         Austin Travis New Construct…     150000000
#> 16 TABS2022005790 "Casting"           Austin Travis New Construct…     109000000
#> 17 TABS2022005789 "Paint"             Austin Travis New Construct…     126000000
#> 18 TABS2022005788 "General Assembly " Austin Travis New Construct…     493000000
#> # ℹ 7 more variables: ProjectStatus <chr>, ProjectId <chr>, ProjectName <chr>,
#> #   ProjectCreatedOn <chr>, DataVersionId <int>, EstimatedStartDate <chr>,
#> #   EstimatedEndDate <chr>
```
