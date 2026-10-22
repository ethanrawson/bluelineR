# Players

`nhl_player()` is a player's page: biography, his featured and career
numbers, every season he played (`season_totals`), his last five games
and his awards. `nhl_player_game_log()` is every game of a season.
`nhl_player_search()` finds players by name, active or retired.

## Usage

``` r
nhl_player(player_id)

nhl_player_game_log(player_id, season = NULL, game_type = "regular")

nhl_player_search(query, active = NULL, limit = 20)
```

## Arguments

- player_id:

  NHL player id, e.g. `8478402` (Connor McDavid).

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md));
  `NULL` for the current one.

- game_type:

  `"regular"` or `"playoffs"`.

- query:

  A name, or part of one.

- active:

  `TRUE` for current players only, `FALSE` for retired ones, `NULL` for
  both.

- limit:

  Most results to return.

## Value

`nhl_player()`: a named list of tibbles (`bio`, `season_totals`,
`last_5_games`, `awards`, `career_totals`); the others: a tibble.

## Examples

``` r
if (FALSE) { # interactive()
p <- nhl_player(8478402)
p$bio
nhl <- p$season_totals[p$season_totals$league_abbrev == "NHL", ]
nhl[, c("season", "games_played", "goals", "points")]
nhl_player_game_log(8478402, "2025-26")
nhl_player_search("hughes")
}
```
