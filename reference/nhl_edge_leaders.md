# NHL EDGE leaderboards

The NHL's EDGE top 10s, all thirteen of them: fastest skaters, most
distance skated, hardest shots, most offensive-zone time and shots by
area for skaters; skating speed, shot speed, distance, zone time and
shots by area for clubs; and 5-on-5 save percentage, save percentage by
area and games above .900 for goalies. `landing` gives the leaders the
EDGE home pages show for skaters, goalies or teams.

## Usage

``` r
nhl_edge_leaders(
  metric = c("skater_speed", "skater_distance", "skater_shot_speed", "skater_zone_time",
    "skater_shot_location", "team_skating_speed", "team_shot_speed",
    "team_skating_distance", "team_zone_time", "team_shot_location", "goalie_5v5",
    "goalie_shot_location", "goalie_save_pct"),
  position = c("all", "F", "D"),
  strength = c("all", "es", "pp", "pk"),
  sort_by = NULL,
  area = c("all", "high", "mid", "long"),
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

  Which leaderboard: `"skater_speed"`, `"skater_distance"`,
  `"skater_shot_speed"`, `"skater_zone_time"`, `"skater_shot_location"`,
  `"team_skating_speed"`, `"team_shot_speed"`,
  `"team_skating_distance"`, `"team_zone_time"`, `"team_shot_location"`,
  `"goalie_5v5"`, `"goalie_shot_location"` or `"goalie_save_pct"`.

- position:

  `"all"`, `"F"` (forwards) or `"D"` (defence).

- strength:

  For distance and zone time: `"all"`, `"es"` (even strength), `"pp"` or
  `"pk"`.

- sort_by:

  The ranking (`NULL` picks the first): for skating speed `"max"`,
  `"over-22"`, `"20-22"`, `"18-20"` (bursts in mph); for shot speed
  `"max"`, `"over-100"`, `"90-99"`, `"80-89"`, `"70-79"`; for distance
  `"total"`, `"per-60"`, `"max-game"`, `"max-period"`; for zone time
  `"offensive"`, `"neutral"`, `"defensive"`; for shot location `"sog"`,
  `"goals"`, `"shooting-pctg"`; for goalies' 5 on 5 `"save-pctg"`,
  `"save-pctg-close"`, `"shots"`, `"shots-per-60"`; for goalies by area
  `"save-pctg"`; for games above .900 `"pctg"` or `"games"`.

- area:

  For shot location: `"all"`, `"high"` (high danger), `"mid"` or
  `"long"`.

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
nhl_edge_leaders("skater_shot_location", sort_by = "goals", area = "high")
nhl_edge_leaders("team_zone_time", strength = "pp")
nhl_edge_leaders("goalie_5v5", sort_by = "save-pctg-close")
nhl_edge_landing("goalie")
}
```
