# Season and game type helpers

`nhl_season()` turns the ways people write a season into the NHL's
eight-digit id: `2025`, `"2025-26"` and `20252026` are all `20252026`.
With no argument it is the current season (a new one starts in August).

## Usage

``` r
nhl_season(season = NULL, date = Sys.Date())

nhl_game_type(game_type = "regular")
```

## Arguments

- season:

  A season as a start year, `"2025-26"` or `20252026`, or `NULL` for the
  current one.

- date:

  Date the current season is worked out from.

- game_type:

  `"regular"`, `"playoffs"` or `"preseason"`, or the NHL's code for one
  (2, 3, 1).

## Value

The season id, a number like `20252026`.

For `nhl_game_type()`, the code: 1, 2 or 3.

## Examples

``` r
nhl_season("2023-24")
#> [1] 20232024
nhl_season(2024)
#> [1] 20242025
nhl_season(as.Date("2026-01-15") |> format("%Y") |> as.numeric() - 1)
#> [1] 20252026
nhl_game_type("playoffs")
#> [1] 3
```
