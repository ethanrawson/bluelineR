# Club stats

Every skater's and goalie's numbers for one club and season.

## Usage

``` r
nhl_team_stats(team, season = NULL, game_type = "regular")
```

## Arguments

- team:

  Club abbreviation (`"EDM"`).

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md)),
  or `"current"`.

- game_type:

  `"regular"` or `"playoffs"`.

## Value

A list of tibbles: `skaters` and `goalies`.

## Examples

``` r
if (FALSE) { # interactive()
nhl_team_stats("EDM", "2025-26")$skaters
}
```
