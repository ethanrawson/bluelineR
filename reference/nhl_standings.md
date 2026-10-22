# Standings

The league table on a date: points, record, goal differential, streaks,
home and road splits and the last ten games, one row per club.

## Usage

``` r
nhl_standings(date = NULL)
```

## Arguments

- date:

  A date (or `"YYYY-MM-DD"`); `NULL` or `"now"` for today.

## Value

A tibble, one row per club.

## Examples

``` r
if (FALSE) { # interactive()
nhl_standings()
nhl_standings("2026-04-15")
}
```
