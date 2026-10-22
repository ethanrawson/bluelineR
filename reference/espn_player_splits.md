# A player's splits, from ESPN

ESPN's splits for a season: home and away, by opponent, by month, in
wins and losses, by day of the week, by conference and division and by
days of rest, each with games, goals, assists, points, plus-minus,
shots, faceoff %, power-play and shorthanded points and ice time a game.

## Usage

``` r
espn_player_splits(athlete_id, season = NULL)
```

## Arguments

- athlete_id:

  ESPN athlete id (McDavid is `3895074`;
  [`espn_props()`](https://ethanrawson.github.io/bluelineR/reference/espn_odds.md)
  has them for every player with a prop).

- season:

  Year the season ends (`2027` for 2026-27); `NULL` for the current one.

## Value

A tibble, one row per split.

## Examples

``` r
if (FALSE) { # interactive()
espn_player_splits(3895074)
}
```
