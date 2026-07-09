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
#>   ProjectId             ProjectNumber ProjectName ProjectCreatedOn ProjectStatus
#>   <chr>                 <chr>         <chr>       <chr>            <chr>        
#> 1 2d1d3a91-4163-4a87-8… TABS20240143… Downtown R… 2024-03-21T14:0… Review Compl…
#> 2 c6f14339-97c4-47c3-8… TABS20240138… Caldwell C… 2024-03-15T07:1… Review Compl…
#> # ℹ 8 more variables: FacilityName <chr>, City <chr>, County <chr>,
#> #   TypeOfWork <chr>, EstimatedCost <dbl>, DataVersionId <int>,
#> #   EstimatedStartDate <chr>, EstimatedEndDate <chr>
GetProjects(
  city = "Austin",
  owner = "Tesla",
  reg_begin = "01/01/20",
  reg_end = "01/01/24"
)
#> # A tibble: 18 × 13
#>    ProjectId            ProjectNumber ProjectName ProjectCreatedOn ProjectStatus
#>    <chr>                <chr>         <chr>       <chr>            <chr>        
#>  1 5e9807b6-2e19-4321-… TABS20240050… Tesla - Au… 2023-11-09T16:2… Review Compl…
#>  2 10bfef25-1f11-4d69-… TABS20240050… Tesla - Au… 2023-11-09T15:5… Review Compl…
#>  3 cb51ea73-45d2-42e9-… TABS20240050… Tesla - Au… 2023-11-09T15:2… Inspection C…
#>  4 f4fe51eb-f383-49a4-… TABS20240016… Tesla - CY… 2023-09-25T15:2… Review Compl…
#>  5 73e58c62-18a8-4cc5-… TABS20240015… Tesla - Au… 2023-09-22T11:3… Project Regi…
#>  6 1a606421-df95-45f2-… TABS20230224… Tesla - Au… 2023-06-28T13:3… Review Compl…
#>  7 6eeb5963-58b7-41b6-… TABS20230145… Tesla - Au… 2023-03-21T08:4… Inspection C…
#>  8 cb1db4ea-f42d-4246-… TABS20230090… Tesla Inc.  2023-01-10T15:1… Project Clos…
#>  9 e85eb537-95c8-407e-… TABS20230089… Tesla Inc.  2023-01-09T15:5… Review Compl…
#> 10 73e05b7b-333a-4fca-… TABS20230089… Tesla Inc.  2023-01-09T15:4… Review Compl…
#> 11 b45fdc21-7e8f-41a5-… TABS20230089… Tesla Inc.  2023-01-09T13:2… Project Clos…
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
