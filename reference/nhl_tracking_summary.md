# Game tracking summaries

The NHL's tracking vendor writes three files per game alongside the
play-by-play, at `live.nhle.com/ppt/{season}/{game}`. NHL.com's tracking
module reads them; they are not among the NHL EDGE endpoints.

## Usage

``` r
nhl_tracking_summary(game_id)

nhl_tracking_player_stats(game_id)

nhl_tracking_entities(game_id)
```

## Arguments

- game_id:

  Ten-digit NHL game id.

## Value

`nhl_tracking_summary()`: a list of tibbles, `players`, `teams`, `puck`
and `info`. The others: a tibble.

## Details

- `nhl_tracking_summary()`: each player's game from the tracking: time
  on the ice, top and average skating speed, distance, time and shift
  starts in each zone, and **puck possession time** (in all, by zone and
  by strength), with each club's possession time and share by zone and
  strength, and the puck's own top speed.

- `nhl_tracking_player_stats()`: the vendor's box score: ice time by
  strength (5v5, 5v4, 4v5...), shifts and their lengths, faceoffs by
  zone and strength, shots by strength, and each shift as a list-column.

- `nhl_tracking_entities()`: who the tracking follows: players (with
  their NHL id, height, weight, handedness), officials and the puck.

Speeds are in miles per hour (`speed_max_mph`, `speed_avg_mph`; the
files keep feet per second), distances in miles and feet, times in
seconds.

**Coverage**: the summaries and player stats exist for most
regular-season games from 2021-22 to 2023-24, some of 2020-21 and
2024-25, and none from 2025-26 on, when only the entity list is still
written. Playoff games are mostly missing.

## Examples

``` r
if (FALSE) { # interactive()
tr <- nhl_tracking_summary(2023020500)
tr$teams[, c("team", "possession_pct", "possession_pct_o_zone")]
top <- tr$players[order(-tr$players$possession_time), ]
top[, c("name", "team", "possession_time", "speed_max_mph", "distance_miles")]
}
```
