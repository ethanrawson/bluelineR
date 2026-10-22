# Best-on-best international hockey

The NHL's records of the tournaments its players have played in: the
Canada Cup (1976 to 1991), the World Cup of Hockey (1996, 2004, 2016),
the Olympics (1998 to 2014, and 2026) and the 4 Nations Face-Off (2025).

## Usage

``` r
nhl_international(
  type = c("skater", "goalie", "team"),
  tournament = NULL,
  year = NULL
)

nhl_international_careers(type = c("skater", "goalie"), olympics = FALSE)

nhl_international_games(tournament = NULL, year = NULL)

nhl_international_winners()

nhl_olympic_podiums()
```

## Arguments

- type:

  `"skater"`, `"goalie"` or, for `nhl_international()`, `"team"`.

- tournament:

  `"olympics"`, `"world cup"`, `"canada cup"` or `"4 nations"`; `NULL`
  for all of them.

- year:

  Year or years the tournament was played; `NULL` for all.

- olympics:

  `TRUE` for Olympic careers and medals.

## Value

A tibble.

## Details

- `nhl_international()`: every player's or club's numbers at each
  tournament, with skaters' ice time from 2010 on.

- `nhl_international_careers()`: career totals across the Canada Cup,
  World Cup and 4 Nations, or with `olympics = TRUE`, across the
  Olympics, with medals.

- `nhl_international_games()`: every game, with the round, score,
  goalies, coaches, three stars and the winning goal. The game ids work
  with
  [`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md)
  and
  [`nhl_boxscore()`](https://ethanrawson.github.io/bluelineR/reference/nhl_boxscore.md):
  full play-by-play for the 4 Nations and the 2016 World Cup, goals and
  penalties for the Olympics. Goals at the 4 Nations have puck and
  player tracking as well, for
  [`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md)
  and
  [`animate_goal()`](https://ethanrawson.github.io/bluelineR/reference/animate_goal.md).

- `nhl_international_winners()`: the game that decided each tournament,
  with the captains, the winning goalie and who scored the winner.

- `nhl_olympic_podiums()`: gold, silver and bronze at each Olympics,
  with captains and coaches.

Tournaments are named by the year they were played (`year = 2026`), not
the NHL season they fell in.

## Examples

``` r
if (FALSE) { # interactive()
# Scoring at the 2026 Olympics:
oly <- nhl_international("skater", "olympics", 2026)
head(oly[, c("first_name", "last_name", "tri_code", "games_played", "goals", "assists", "points")])

# Every 4 Nations game, then the final's play-by-play:
games <- nhl_international_games("4 nations")
nhl_pbp(games$game_id[games$series_title == "Final"])

# McDavid's overtime winner in the final, from the tracking:
animate_goal(nhl_goal_tracking(2024200007, 1443), "mcdavid-4-nations.mp4",
             goal = nhl_goal_replay(2024200007, 1443))

nhl_international_careers("skater")
nhl_international_careers("goalie", olympics = TRUE)
nhl_international_winners()
nhl_olympic_podiums()
}
```
