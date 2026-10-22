# Goal tracking frames

The NHL replays every goal from puck and player tracking: about 14
seconds of every skater, both goalies and the puck, ten frames a second,
for every goal from 2023-24 on. `nhl_goal_tracking()` returns those
frames, one row per object per frame, with positions in feet from centre
ice in the play-by-play's orientation (x along the rink, y across it).

## Usage

``` r
nhl_goal_tracking(game_id, event_id)

nhl_goal_replay(game_id, event_id)
```

## Arguments

- game_id:

  Ten-digit NHL game id.

- event_id:

  The goal's event id in the play-by-play (`event_id` in
  [`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md)).

## Value

`nhl_goal_tracking()`: a tibble with columns `frame`, `time` (seconds
from the first frame), `entity_id`, `is_puck`, `player_id`,
`sweater_number`, `team`, `x`, `y`. The goal's game and event ids ride
along as attributes. `nhl_goal_replay()`: a one-row tibble.

## Details

The files live on `wsr.nhle.com` and answer only requests that come from
nhl.com, so the request says it does (a `Referer` header).
`nhl_goal_replay()` is the goal itself as the NHL's replay page has it:
scorer, assists, strength, the score, both clubs' logos and the
highlight video.

## Examples

``` r
if (FALSE) { # interactive()
frames <- nhl_goal_tracking(2025020534, 777)
plot_goal(frames)
nhl_goal_replay(2025020534, 777)
}
```
