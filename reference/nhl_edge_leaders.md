# NHL EDGE leaderboards

The NHL's EDGE top 10s: fastest skaters, most distance skated, hardest
shots, most offensive-zone time, and the clubs' skating speed. `landing`
gives the leaders the EDGE home pages show for skaters, goalies or
teams.

## Usage

``` r
nhl_edge_leaders(
  metric = c("skater_speed", "skater_distance", "skater_shot_speed", "skater_zone_time",
    "team_skating_speed"),
  position = c("all", "F", "D"),
  strength = c("all", "es", "pp", "pk"),
  sort_by = NULL,
  season = NULL,
  game_type = "regular"
)

nhl_edge_landing(
  type = c("skater", "goalie", "team"),
  season = NULL,
  game_type = "regular"
)
```

## Arguments

- metric:

  Which leaderboard.

- position:

  `"all"`, `"F"` (forwards) or `"D"` (defence).

- strength:

  For distance and zone time: `"all"`, `"es"` (even strength), `"pp"` or
  `"pk"`.

- sort_by:

  The ranking: for speed and shot speed `"max"` (top speed) or a burst
  band (`"over22"`, `"20-22"`, `"18-20"` for skating speed; `"over100"`,
  `"90-100"`, `"80-90"`, `"70-80"` for shot speed); for distance
  `"total"` or `"max-game"`; for zone time `"offensive"`, `"neutral"` or
  `"defensive"`. `NULL` picks the first.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md));
  `NULL` for the current one.

- game_type:

  `"regular"` or `"playoffs"`.

- type:

  `"skater"`, `"goalie"` or `"team"`.

## Value

A tibble, one row per player or club.

## Examples

``` r
if (FALSE) { # interactive()
nhl_edge_leaders("skater_speed")
nhl_edge_leaders("skater_shot_speed", position = "D")
nhl_edge_landing("goalie")
}
```
