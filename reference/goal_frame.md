# When the puck went in

The frame a goal was scored on: the first time the puck is over the goal
line, between the posts and no deeper than the net, for two frames
running, at the net it finishes the clip in. (The first frame in any net
is wrong on about one goal in five: a clip can open with the puck at the
other net, or blip over the line before the real goal.)

## Usage

``` r
goal_frame(frames)
```

## Arguments

- frames:

  Tracking frames from
  [`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md).

## Value

The frame number, or `NA` if the puck never goes in.

## Examples

``` r
path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
goal_frame(read_goal_tracking(path))
#> [1] 99
```
