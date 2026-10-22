# Era-adjusted stats

Rescales each season to one scoring environment, by default the average
of the last ten completed seasons over an 82-game schedule, so a 1952
season and a 2022 one read on the same scale:

## Usage

``` r
nhl_era_adjust(stats, baseline = NULL, env = nhl_league_env())
```

## Arguments

- stats:

  Player seasons: `goals` and `assists` for skaters,
  `goals_against_average` (or `goals_against_avg`) and `save_pct` (or
  `save_pctg`) for goalies.

- baseline:

  The seasons, as start years, whose average is the standard; the
  default is the last ten in
  [`nhl_league_env()`](https://ethanrawson.github.io/bluelineR/reference/nhl_league_env.md).

- env:

  The environment table;
  [`nhl_league_env()`](https://ethanrawson.github.io/bluelineR/reference/nhl_league_env.md)
  by default.

## Value

`stats` with `adj_goals`, `adj_assists` and `adj_points` (skater columns
present) and `adj_gaa` and `save_pct_vs_league` (goalie columns
present).

## Details

- goals by the league's goals a game, assists by its assists a game,
  both by the schedule (to 82 games) and by roster size (skaters dressed
  a game: a 1920s star shared the scoring with nine or ten teammates,
  not seventeen), as Hockey-Reference adjusts;

- a goalie's goals-against average by the league's goals a game, and his
  save percentage against the league's that season.

Works on any table of player seasons with a season column (`season_id`
from
[`nhl_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stats.md),
`season` from
[`nhl_player()`](https://ethanrawson.github.io/bluelineR/reference/nhl_player.md)'s
`season_totals`). Only NHL regular seasons are adjusted; other leagues,
the playoffs and any season
[`nhl_league_env()`](https://ethanrawson.github.io/bluelineR/reference/nhl_league_env.md)
does not cover (the one in progress) get `NA`.

## Examples

``` r
gretzky <- data.frame(season_id = c(19811982, 19851986), goals = c(92, 52), assists = c(120, 163))
nhl_era_adjust(gretzky)
#>   season_id goals assists adj_goals adj_assists adj_points
#> 1  19811982    92     120   66.2495    88.28109   154.5306
#> 2  19851986    52     163   40.0524   128.55935   168.6118
```
