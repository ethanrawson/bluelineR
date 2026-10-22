# Stat leaders

The league leaders the NHL's stats pages open with: for skaters goals,
assists, points, plus-minus, power-play and shorthanded goals, penalty
minutes, faceoffs and ice time; for goalies wins, shutouts, save
percentage and goals-against average.

## Usage

``` r
nhl_stat_leaders(
  type = c("skater", "goalie"),
  season = NULL,
  game_type = "regular",
  categories = NULL,
  limit = NULL
)
```

## Arguments

- type:

  `"skater"` or `"goalie"`.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md)),
  or `"current"`.

- game_type:

  `"regular"` or `"playoffs"`.

- categories:

  Categories to return, e.g. `c("goals", "points")`; `NULL` for all.

- limit:

  Players per category.

## Value

A tibble: `category`, `rank` and the player's details and value.

## Examples

``` r
if (FALSE) { # interactive()
nhl_stat_leaders("skater", categories = "goals", limit = 10)
}
```
