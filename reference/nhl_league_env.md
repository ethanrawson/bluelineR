# Each season's scoring environment

Every completed NHL regular season since 1917-18: the games each club
played, goals and assists per team-game, skaters dressed per team-game
and the league save percentage (from 1955-56, when the NHL started
counting shots against).
[`nhl_era_adjust()`](https://ethanrawson.github.io/bluelineR/reference/nhl_era_adjust.md)
rescales players' seasons by it.

## Usage

``` r
nhl_league_env(refresh = FALSE)
```

## Arguments

- refresh:

  Rebuild from the API instead of using the shipped table.

## Value

A tibble, one row per season.

## Details

The table ships with the package, so it works offline; `refresh = TRUE`
rebuilds it from the stats API (three requests a season, so a minute or
two), for a season completed since this version.

## Examples

``` r
env <- nhl_league_env()
env[env$season %in% c(19551956, 19811982, 20252026), ]
#> # A tibble: 3 × 6
#>     season schedule goals_per_game assists_per_game skaters_per_game save_pct
#>      <dbl>    <dbl>          <dbl>            <dbl>            <dbl>    <dbl>
#> 1 19551956       70           2.53             4.03             15.4    0.919
#> 2 19811982       80           4.01             6.61             16.9    0.873
#> 3 20252026       82           3.08             5.20             18.0    0.896
```
