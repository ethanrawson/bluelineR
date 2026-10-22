# Play-by-play

Every event in a game, one row each, with the clock as seconds, the
strength (`situation_code` read as skaters a side), the players involved
by id and name, the running score, and the location twice: as the feed
has it (`x`, `y`, feet from centre ice) and turned so the event's team
always attacks to the right (`x_fixed`, `y_fixed`), the usual frame for
shot maps.

## Usage

``` r
nhl_pbp(game_id)
```

## Arguments

- game_id:

  Ten-digit NHL game id, e.g. `2025020534`.

## Value

A tibble, one row per event.

## Details

Every game since 1917-18 has a play-by-play, but the early ones are
short: goals and penalties only until 1997-98, shots on goal added from
then, and every event with its location from 2009-10 (see
[`nhl_stat_eras()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stat_eras.md)).

## Examples

``` r
if (FALSE) { # interactive()
pbp <- nhl_pbp(2025020534)
pbp[pbp$type == "goal", c("period", "time_in_period", "event_team", "player_1_name")]
}
```
