# Shot map

A game's shots on the rink, every club attacking to the right
(`x_fixed`, `y_fixed` from
[`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md)):
goals, saves and misses.

## Usage

``` r
plot_shots(pbp, team = NULL)
```

## Arguments

- pbp:

  Play-by-play from
  [`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md).

- team:

  Only this club's shots; `NULL` for both, coloured by club.

## Value

A ggplot.

## Examples

``` r
if (FALSE) { # interactive()
plot_shots(nhl_pbp(2025020534))
}
```
