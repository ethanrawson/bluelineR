# Contracts and trades

NHL contract and trade data from Sportsnet's stats API, which publishes
PuckPedia's tracker (the NHL's own APIs have none):

## Usage

``` r
nhl_signings(year = NULL, by_season = FALSE)

nhl_trades(season = NULL, assets = FALSE)
```

## Arguments

- year:

  Calendar year the contracts were signed; `NULL` for this year.

- by_season:

  One row per season of each contract.

- season:

  Season (see
  [`nhl_season()`](https://ethanrawson.github.io/bluelineR/reference/nhl_season.md))
  or seasons the trades were made in; `NULL` for every one.

- assets:

  One row per player or pick moved, instead of per trade.

## Value

A tibble.

## Details

- `nhl_signings()`: every contract signed in a calendar year: the
  player, the club, the term and total value, the average annual value,
  whether he signed as an RFA or UFA and what he will be when it ends,
  and any no-trade or no-movement clause. With `by_season = TRUE`, one
  row per season of each contract: cap hit, base salary, signing and
  performance bonuses, the clause that season, and the cap hit as a
  share of that season's salary cap.

- `nhl_trades()`: every trade since 2020-21, one row per trade, or with
  `assets = TRUE` one row per player or pick moved: who got him, his cap
  hit and how much was retained, his contract's term and expiry, and for
  a pick its year, round and original club.

Signings are fullest from 2025 on (a few dozen a year before that).

## Examples

``` r
if (FALSE) { # interactive()
s <- nhl_signings(2026)
s <- s[order(-s$aav), ]
s[, c("player_name", "team", "contract_length", "aav", "signing_status", "clause")]

# Cap hits season by season:
nhl_signings(2026, by_season = TRUE)

trades <- nhl_trades("2025-26", assets = TRUE)
players <- trades[trades$asset_type == "player", ]
players[, c("trade_date", "team", "player_name", "cap_hit", "retained_hit")]
}
```
