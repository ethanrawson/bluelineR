# The NHL's quick standings and leaders

The small static files NHL.com's scoreboard pages load
(`live.nhle.com/psr`): the standings by division, each club's power play
and penalty kill, and the skater (goals, assists, points, shots) and
goalie leaders. Quicker than the full standings and stats endpoints when
the headline numbers are all you need.

## Usage

``` r
nhl_quick_stats(
  feed = c("standings", "power_play", "skater_leaders", "goalie_leaders"),
  season = NULL
)
```

## Arguments

- feed:

  `"standings"`, `"power_play"`, `"skater_leaders"` or
  `"goalie_leaders"`.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md));
  `NULL` for the current one.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # interactive()
nhl_quick_stats("power_play")
nhl_quick_stats("skater_leaders")
}
```
