# Skating speed from tracking

Each skater's speed in miles per hour at every frame, over the 0.6
seconds around it (three frames each way), as the NHL's replays show it.

## Usage

``` r
skater_speed(frames)
```

## Arguments

- frames:

  Tracking frames from
  [`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md).

## Value

`frames` without the puck, plus a `speed_mph` column.

## Examples

``` r
path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
spd <- skater_speed(read_goal_tracking(path))
spd[which.max(spd$speed_mph), c("frame", "player_id", "speed_mph")]
#> # A tibble: 1 × 3
#>   frame player_id speed_mph
#>   <int>     <dbl>     <dbl>
#> 1    81   8478402      20.3
```
