# DraftKings odds and player props, from ESPN

ESPN's NHL odds come from DraftKings, and its APIs (unlike DraftKings'
own, which refuse requests from servers) are open:

## Usage

``` r
espn_odds(date = NULL)

espn_props(date = NULL, nhl_ids = TRUE)
```

## Arguments

- date:

  A date (or `"YYYY-MM-DD"`); `NULL` for today.

- nhl_ids:

  Add each player's NHL id (four more requests a game).

## Value

A tibble.

## Details

- `espn_odds()`: every game's moneyline, puck line and total, opening
  and current, with the no-vig chance of each side.

- `espn_props()`: DraftKings' player props for a day's games, about 500
  a game: shots on goal, points, assists, saves, anytime and first
  goalscorer, the "2+ shots" style milestones, power-play points, and
  each club's goal total. Each over/under comes as one row with both
  prices. With `nhl_ids = TRUE` every player gets his NHL id, for
  joining to the rest of the package.

ESPN lists an over/under as two entries without naming the sides, over
first: in every pair checked against the same player's milestone prices
(October 2026), the first entry was the over. Players come as ESPN ids
and are matched to NHL rosters by club, sweater number and surname, then
by name. ESPN drops a game's odds once it starts.

## See also

[`devig()`](https://ethanrawson.github.io/bluelineR/reference/devig.md)
for the no-vig chance of any pair of prices.

## Examples

``` r
if (FALSE) { # interactive()
espn_odds()
props <- espn_props()
props[props$market == "Total Shots on Goal", c("player_name", "team", "line", "over", "under")]
}
```
