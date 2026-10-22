# Shot map

A game's shots on the rink, each club's at the net it attacks: the away
club's at the left end and the home club's at the right, the way a game
is usually drawn, for the whole game (the play-by-play's `x_fixed`,
`y_fixed`, turned back for the away club). Goals, saves and misses.
`sides = "right"` puts every shot at the right-hand net instead, which
compares the clubs' shot locations on top of each other; a single club
(`team`) always attacks right.

## Usage

``` r
plot_shots(pbp, team = NULL, sides = c("both", "right"))
```

## Arguments

- pbp:

  Play-by-play from
  [`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md),
  or an IIHF game's shots from
  [`iihf_shots()`](https://ethanrawson.github.io/bluelineR/reference/iihf.md).

- team:

  Only this club's shots; `NULL` for both, coloured by club.

- sides:

  `"both"`: each club at its own end (away left, home right). `"right"`:
  every shot at the right-hand net.

## Value

A ggplot.

## Examples

``` r
if (FALSE) { # interactive()
pbp <- nhl_pbp(2025020534)
plot_shots(pbp)
plot_shots(pbp, sides = "right")
plot_shots(pbp, team = "EDM")
}
```
