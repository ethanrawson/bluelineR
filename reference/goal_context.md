# A goal's context from the play-by-play

Looks back from a goal to the last stoppage: a rebound (the same club
had a shot on goal in the 3 seconds before) and a goal off a faceoff the
club won in the offensive zone, or lost in its own (within 10 seconds).

## Usage

``` r
goal_context(pbp, event_id)
```

## Arguments

- pbp:

  Play-by-play from
  [`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md).

- event_id:

  The goal's event id.

## Value

A one-row tibble: `event_id`, `rebound`, `faceoff`.

## Examples

``` r
if (FALSE) { # interactive()
pbp <- nhl_pbp(2025020534)
goal_context(pbp, 777)
}
```
