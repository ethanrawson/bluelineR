# Scores and the schedule

`nhl_scores()` is every game on a date with its score and state (the
NHL's scoreboard). `nhl_schedule()` is the week of games starting on a
date. `nhl_team_schedule()` is one club's whole season.

## Usage

``` r
nhl_scores(date = NULL)

nhl_schedule(date = NULL)

nhl_team_schedule(team, season = NULL)
```

## Arguments

- date:

  A date (or `"YYYY-MM-DD"`); `NULL` or `"now"` for today.

- team:

  Club abbreviation (`"EDM"`) or team id.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md));
  `NULL` for the current one.

## Value

A tibble, one row per game.

## Examples

``` r
if (FALSE) { # interactive()
nhl_scores("2026-10-20")
nhl_schedule()
nhl_team_schedule("EDM", "2025-26")
}
```
