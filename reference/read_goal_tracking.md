# Read tracking frames from a file

Parses a tracking file saved from `wsr.nhle.com` (the JSON
[`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md)
downloads) into the same tibble. The package ships one, Connor McDavid's
shorthanded breakaway goal at Boston on 18 December 2025:
`system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")`.

## Usage

``` r
read_goal_tracking(path, game_id = NA, event_id = NA)
```

## Arguments

- path:

  Path to the JSON file (gzipped or not).

- game_id, event_id:

  Kept as attributes, as
  [`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md)
  does.

## Value

A tibble of frames; see
[`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md).

## Examples

``` r
path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
frames <- read_goal_tracking(path, 2025020534, 777)
head(frames)
#> # A tibble: 6 × 9
#>   frame  time entity_id is_puck player_id sweater_number team      x       y
#>   <int> <dbl>     <dbl> <lgl>       <dbl>          <dbl> <chr> <dbl>   <dbl>
#> 1     1     0         1 TRUE           NA             NA NA     77.9 -30.7  
#> 2     1     0      6001 FALSE     8480280              1 BOS   -87.3  -0.403
#> 3     1     0      6018 FALSE     8478401             18 BOS    81.0  -4.75 
#> 4     1     0      6028 FALSE     8477496             28 BOS    54.4  -0.288
#> 5     1     0      6039 FALSE     8479987             39 BOS    57.7  15.4  
#> 6     1     0      6073 FALSE     8479325             73 BOS    44.9 -25.2  
```
