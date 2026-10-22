# Two clubs side by side

The NHL's team comparison: power play and penalty kill, faceoffs, goals
for and against a game and the rest of the headline numbers for two
clubs, each with its league rank.

## Usage

``` r
nhl_team_comparison(team_a, team_b, season = NULL, game_type = "regular")
```

## Arguments

- team_a, team_b:

  Club abbreviations (`"EDM"`) or team ids.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md)),
  or `"current"`.

- game_type:

  `"regular"` or `"playoffs"`.

## Value

A tibble, one row per stat: each club's value and rank.

## Examples

``` r
if (FALSE) { # interactive()
nhl_team_comparison("EDM", "TOR")
}
```
