# Game summary

The gamecenter landing page's data, tidied: the scoring summary, three
stars, penalties and the clubs, as tibbles (see
[`tidy_json()`](https://ethanrawson.github.io/bluelineR/reference/tidy_json.md)).

## Usage

``` r
nhl_game(game_id)
```

## Arguments

- game_id:

  Ten-digit NHL game id, e.g. `2025020534`.

## Value

A named list of tibbles.

## Examples

``` r
if (FALSE) { # interactive()
game <- nhl_game(2025020534)
game$info
}
```
