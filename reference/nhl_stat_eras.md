# What the NHL kept, and since when

The NHL's numbers do not all go back to 1917-18. Goals, assists and
penalty minutes do, for every season and every game; shots, plus/minus,
ice time, hits and shot locations each start later, and a column the
league did not keep comes back missing for the seasons before it. These
tables say where each one starts, measured against the live API.

## Usage

``` r
nhl_stat_eras(by = c("era", "stat"), stat = NULL)
```

## Arguments

- by:

  `"era"` or `"stat"`.

- stat:

  With `by = "stat"`, column names to keep (as bluelineR returns them,
  e.g. `"shots"`, `"hits"`, `"time_on_ice_per_game"`).

## Value

A tibble. Seasons are written like `"1959-60"`.

## Details

`nhl_stat_eras()` gives the eras: what each adds and the bluelineR
functions that reach it. With `by = "stat"` it gives the first season of
every column of the stats reports
([`nhl_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stats.md));
`stat` keeps the ones named.

## Examples

``` r
nhl_stat_eras()
#> # A tibble: 14 × 4
#>    from    to      adds                                                functions
#>    <chr>   <chr>   <chr>                                               <chr>    
#>  1 1917-18 NA      Games, goals, assists, points, penalty minutes and… "nhl_sta…
#>  2 1933-34 NA      Even-strength, power-play and short-handed goals a… "nhl_sta…
#>  3 1955-56 NA      Goalies' shots against, saves, save percentage and… "nhl_sta…
#>  4 1959-60 NA      Skaters' shots and plus/minus (shooting percentage… "nhl_sta…
#>  5 1977-78 NA      Team power-play and penalty-kill percentages, with… "nhl_sta…
#>  6 1997-98 NA      Ice time and shifts, at even strength, on the powe… "nhl_sta…
#>  7 1999-00 NA      Teams' overtime losses (goalies' from 2005-06)      "nhl_sta…
#>  8 2005-06 NA      Hits, blocked shots, giveaways, takeaways and miss… "nhl_sta…
#>  9 2009-10 NA      Every event in the play-by-play with its location … "nhl_pbp…
#> 10 2010-11 NA      Shift charts                                        "nhl_shi…
#> 11 2021-22 NA      NHL EDGE puck and player tracking: skating speed a… "nhl_edg…
#> 12 2021-22 2023-24 Game tracking summaries (also some games of 2020-2… "nhl_tra…
#> 13 2022-23 NA      Each skater's total shot attempts and attempts blo… "nhl_sta…
#> 14 2023-24 NA      Goal tracking: every player and the puck through e… "nhl_goa…
nhl_stat_eras("stat", c("shots", "plus_minus", "hits"))
#> # A tibble: 5 × 3
#>   report          stat       first_season
#>   <chr>           <chr>      <chr>       
#> 1 skater/summary  shots      1959-60     
#> 2 skater/summary  plus_minus 1959-60     
#> 3 skater/realtime hits       2005-06     
#> 4 team/realtime   shots      1959-60     
#> 5 team/realtime   hits       2005-06     
```
