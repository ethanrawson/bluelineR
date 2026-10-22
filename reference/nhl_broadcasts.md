# Where to watch a game

The NHL's viewing guide for a game: the national and regional networks
carrying it in the US and Canada (each club's local broadcast) and the
streaming options out of market and abroad, with each broadcaster's logo
for light and dark backgrounds where the NHL has one.

## Usage

``` r
nhl_broadcasts(game_id)
```

## Arguments

- game_id:

  Ten-digit NHL game id, e.g. `2025020534`.

## Value

A tibble, one row per broadcaster and market.

## Examples

``` r
if (FALSE) { # interactive()
nhl_broadcasts(2026020066)
}
```
