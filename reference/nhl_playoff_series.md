# Playoff history: series records and every playoff game

From the NHL's records site:

## Usage

``` r
nhl_playoff_series(team, opponent = NULL)

nhl_playoff_games(season)
```

## Arguments

- team:

  Club abbreviation (`"EDM"`) or team id.

- opponent:

  Only the record against this club; `NULL` for all.

- season:

  Season, e.g. `2024` or `"20242025"`.

## Value

A tibble.

## Details

- `nhl_playoff_series()`: a franchise's playoff record against each
  opponent, round by round: series won and lost, games, goals, and how
  their last meeting went.

- `nhl_playoff_games()`: every playoff game of a season (any season back
  to 1918), with the series, the game number in it, the score, the
  coaches, the winning and losing goalies, the three stars and the
  arena.

## Examples

``` r
if (FALSE) { # interactive()
nhl_playoff_series("EDM", "FLA")
nhl_playoff_series("TOR")
nhl_playoff_games(2024)
}
```
