# What is in the records API

A guide to records.nhl.com: every table
[`nhl_records()`](https://ethanrawson.github.io/bluelineR/reference/nhl_records.md)
can fetch, with a line on what it holds and the bluelineR function that
wraps it, if one does. Every resource was checked against the live API.

## Usage

``` r
nhl_records_catalog(pattern = NULL)
```

## Arguments

- pattern:

  Optional regular expression; keeps the rows whose resource or
  description matches (case-insensitive).

## Value

A tibble with `resource`, `about` and `helper`.

## Examples

``` r
nhl_records_catalog()
#> # A tibble: 78 × 3
#>    resource                         about                                 helper
#>    <chr>                            <chr>                                 <chr> 
#>  1 all-star-coach-career-stats      Every All-Star Game coach's record    NA    
#>  2 all-star-goaltender-career-stats All-Star Game goalies, career totals  NA    
#>  3 all-star-goaltender-game-stats   All-Star Game goalies, game by game   NA    
#>  4 all-star-goaltender-period-stats All-Star Game goalies, period by per… NA    
#>  5 all-star-skater-career-stats     All-Star Game skaters, career totals  NA    
#>  6 all-star-skater-game-stats       All-Star Game skaters, game by game   NA    
#>  7 all-star-skater-period-stats     All-Star Game skaters, period by per… NA    
#>  8 all-star-team-game-stats         All-Star Game team results            NA    
#>  9 all-star-team-period-stats       All-Star Game team results by period  NA    
#> 10 all_star_team_position_leaders   Most first- and second-team NHL All-… NA    
#> # ℹ 68 more rows
nhl_records_catalog("all-star")
#> # A tibble: 12 × 3
#>    resource                         about                                 helper
#>    <chr>                            <chr>                                 <chr> 
#>  1 all-star-coach-career-stats      Every All-Star Game coach's record    NA    
#>  2 all-star-goaltender-career-stats All-Star Game goalies, career totals  NA    
#>  3 all-star-goaltender-game-stats   All-Star Game goalies, game by game   NA    
#>  4 all-star-goaltender-period-stats All-Star Game goalies, period by per… NA    
#>  5 all-star-skater-career-stats     All-Star Game skaters, career totals  NA    
#>  6 all-star-skater-game-stats       All-Star Game skaters, game by game   NA    
#>  7 all-star-skater-period-stats     All-Star Game skaters, period by per… NA    
#>  8 all-star-team-game-stats         All-Star Game team results            NA    
#>  9 all-star-team-period-stats       All-Star Game team results by period  NA    
#> 10 all_star_team_position_leaders   Most first- and second-team NHL All-… NA    
#> 11 phwa-all-star-team               The writers' All-Star teams by season NA    
#> 12 season/event                     Special events: outdoor games, Globa… NA    
```
