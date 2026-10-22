# How a goal was scored, from its tracking

Reads a goal's tracking frames the way BluelineMetrics' goal types are
built (bluelinemetrics.com): who released it, from how far and how hard,
and whether it came off the rush, on a breakaway or an odd-man rush, as
a one-timer, across the slot, through traffic, from behind the net or
off the forecheck. Who did what is by NHL player id.

## Usage

``` r
classify_goal(frames, team = NULL, goalie_ids = NULL, shot_type = "")
```

## Arguments

- frames:

  Tracking frames from
  [`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md).

- team:

  The scoring club's abbreviation. Worked out from the frames when
  `NULL` (the club attacking the net the puck ends in), which needs a
  goalie in that net: pass it for empty-net goals.

- goalie_ids:

  NHL player ids of the goalies. When `NULL`, each club's goalie is the
  skater who spends the clip closest to its net.

- shot_type:

  The play-by-play's shot type (`"tip-in"` and `"deflected"` are never
  one-timers).

## Value

A one-row tibble, or `NULL` when the frames do not show the goal.

## Details

A skater has the puck when he is the nearest one within 4 feet of it for
two frames running. The frames are turned so the scoring team attacks
the net at x = +89.

- `rush`: the puck was on the far side of centre ice within 5 seconds of
  the release (`since`, seconds).

- `breakaway`: a rush the shooter carried over the blue line with no
  defender but the goalie between him and the net from there to the
  shot.

- `oddman`: a rush with two or three attackers level with the puck or
  ahead at the blue line and more of them than defenders back.

- `onetimer`: shot within 0.3 s of a teammate's pass, from more than 12
  ft (tips and deflections aside); `otpass` is the passer.

- `cross`: the puck crossed the slot (from one side to the other, 12+
  ft) in the 2 seconds before the release; `xpass` made the pass.

- `traffic`: a skater other than the goalie in the triangle from the
  release to the posts; `screens` are teammates in the shooting lane.

- `behind`: the pass in came from behind the goal line, within 30 ft;
  `bnpass` made it.

- `forecheck`: the other side's last possession, 0.5+ s, was in this
  zone within 5 s of the release and the puck never left the zone;
  `fcwin` is the teammate who won it back.

- `speed`: shot speed (mph), the puck's fastest move in the 0.3 s after
  the release. `passes`: passes since the team last won the puck.

## Examples

``` r
path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
frames <- read_goal_tracking(path, 2025020534, 777)
classify_goal(frames, team = "EDM", shot_type = "backhand")
#> # A tibble: 1 × 25
#>      game_id event_id team  goal_frame release_frame shooter distance shot_speed
#>        <dbl>    <dbl> <chr>      <int>         <int>   <dbl>    <dbl>      <dbl>
#> 1 2025020534      777 EDM           99            96 8478402      7.5       24.1
#> # ℹ 17 more variables: since_neutral <dbl>, passes <dbl>, rush <lgl>,
#> #   breakaway <lgl>, oddman <lgl>, onetimer <lgl>, cross <lgl>, traffic <lgl>,
#> #   behind <lgl>, forecheck <lgl>, kinds <chr>, carrier <dbl>, xpass <dbl>,
#> #   otpass <dbl>, bnpass <dbl>, fcwin <dbl>, screens <list>
```
