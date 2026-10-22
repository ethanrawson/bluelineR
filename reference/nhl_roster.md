# Rosters and prospects

A club's roster for a season (forwards, defencemen and goalies with
height, weight, birthplace and sweater number), or its prospects.

## Usage

``` r
nhl_roster(team, season = "current")

nhl_prospects(team)
```

## Arguments

- team:

  Club abbreviation (`"EDM"`).

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md)),
  or `"current"`.

## Value

A tibble, one row per player.

## Examples

``` r
if (FALSE) { # interactive()
nhl_roster("EDM")
nhl_roster("EDM", "2015-16")
nhl_prospects("CHI")
}
```
