# The NHL stats API

The API behind NHL.com/stats: any report it has (`"skater/summary"`,
`"skater/realtime"`, `"skater/timeonice"`, `"skater/bios"`,
`"goalie/summary"`, `"team/summary"` and many more; see
`nhl_stats_reports()`), by season or game by game, filtered and sorted.

## Usage

``` r
nhl_stats(
  report = "skater/summary",
  season = NULL,
  game_type = "regular",
  filter = NULL,
  sort = NULL,
  limit = -1,
  aggregate = FALSE,
  by_game = FALSE
)

nhl_stats_reports()
```

## Arguments

- report:

  The report, e.g. `"skater/summary"`.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md));
  `NULL` for the current one, or a vector of two for a range.

- game_type:

  `"regular"`, `"playoffs"` or `"preseason"`.

- filter:

  Extra Cayenne expressions, a character vector.

- sort:

  Column to sort by, descending; prefix with `"+"` for ascending.

- limit:

  Rows to return; `-1` for all.

- aggregate:

  `TRUE` sums a range of seasons into one row per player.

- by_game:

  `TRUE` for one row per player per game.

## Value

A tibble.

For `nhl_stats_reports()`, a tibble of the reports the API offers.

## Details

Filters are the API's own Cayenne expressions, joined with `and`:
`filter = "teamAbbrevs='EDM'"`, `filter = "gamesPlayed>=20"`.

Every season back to 1917-18 is there, but not every column: shots and
plus/minus start in 1959-60, ice time in 1997-98, hits in 2005-06.
[`nhl_stat_eras()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stat_eras.md)
has each column's first season, and sorting by one for seasons before it
says so.

## Examples

``` r
if (FALSE) { # interactive()
nhl_stats("skater/summary", "2025-26", sort = "points", limit = 10)
nhl_stats("goalie/summary", filter = "gamesPlayed>=20", sort = "+goalsAgainstAverage")
nhl_stats("skater/realtime", c(2015, 2025), aggregate = TRUE, sort = "hits", limit = 20)
nhl_stats("skater/summary", "1981-82", sort = "points", limit = 5)
}
```
