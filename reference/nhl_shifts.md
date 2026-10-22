# Shift charts

Every shift each player took: when it started and ended (as the period
clock and as seconds into the game) and how long it lasted.

## Usage

``` r
nhl_shifts(game_id, shifts_only = TRUE)
```

## Arguments

- game_id:

  Ten-digit NHL game id, e.g. `2025020534`.

- shifts_only:

  Drop the goal rows the NHL mixes into the chart.

## Value

A tibble, one row per shift.

## Examples

``` r
if (FALSE) { # interactive()
shifts <- nhl_shifts(2025020534)
aggregate(duration_seconds ~ player_name, shifts, sum)
}
```
