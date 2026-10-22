# Franchise records in particular games

Each franchise's all-time record in one kind of game, from
records.nhl.com: Game 7s, overtime, season openers (home, road and
both), outdoor games, games outside North America and other neutral
sites. The neutral-site tables list the venues too.

## Usage

``` r
nhl_franchise_records(
  type = c("game7", "overtime", "season_opener", "outdoor", "outside_na", "neutral_site"),
  game_type = 2
)
```

## Arguments

- type:

  `"game7"`, `"overtime"`, `"season_opener"`, `"outdoor"`,
  `"outside_na"` or `"neutral_site"`.

- game_type:

  2 (regular season) or 3 (playoffs), for `"overtime"` and
  `"neutral_site"`; Game 7s are always playoff games, and the outdoor,
  overseas and season-opener tables are regular season.

## Value

A tibble, one row per franchise (per venue for `"season_opener"`).

## Examples

``` r
if (FALSE) { # interactive()
nhl_franchise_records("game7")
nhl_franchise_records("overtime", game_type = 3)
nhl_franchise_records("outdoor")
}
```
