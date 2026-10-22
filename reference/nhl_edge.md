# NHL EDGE: skaters, goalies and teams

NHL EDGE is the league's puck and player tracking, summed up by season:
skating speed and bursts, distance skated, shot speed, shots by
location, time in each zone and, for goalies, save percentage by
location and at 5-on-5. Each value comes with the league average and a
percentile.

## Usage

``` r
nhl_edge_skater(
  player_id,
  season = NULL,
  game_type = "regular",
  report = c("detail", "speed", "distance", "shot_speed", "zone_time", "shot_location",
    "comparison")
)

nhl_edge_goalie(
  player_id,
  season = NULL,
  game_type = "regular",
  report = c("detail", "5v5", "save_pct", "shot_location", "comparison")
)

nhl_edge_team(
  team,
  season = NULL,
  game_type = "regular",
  report = c("detail", "speed", "distance", "shot_speed", "zone_time", "shot_location",
    "comparison")
)
```

## Arguments

- player_id:

  NHL player id.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md));
  `NULL` for the current one.

- game_type:

  `"regular"` or `"playoffs"`.

- report:

  Which table; see Details.

- team:

  Club abbreviation (`"EDM"`) or team id.

## Value

A named list of tibbles (see
[`tidy_json()`](https://ethanrawson.github.io/bluelineR/reference/tidy_json.md)).

## Details

`report` picks the endpoint: `"detail"` is the overview the NHL's EDGE
pages open with; the others are the full tables behind each tab;
`"comparison"` is everything at once, as the NHL's player comparison
tool uses it.

## Examples

``` r
if (FALSE) { # interactive()
mcdavid <- nhl_edge_skater(8478402, "2025-26")
mcdavid$info
nhl_edge_skater(8478402, report = "speed")$top_skating_speeds
nhl_edge_goalie(8479361, report = "shot_location")
nhl_edge_team("EDM", report = "zone_time")
}
```
