# The no-vig chance of a pair of prices

Takes the bookmaker's margin out of a two-way market by scaling both
implied probabilities to sum to one (the proportional method), and
returns the chance of the first side.

## Usage

``` r
devig(first, second)
```

## Arguments

- first, second:

  American prices of the two sides (`-150`, `+130`). Vectors work; a
  missing price gives `NA`.

## Value

The no-vig probability of `first`.

## Examples

``` r
devig(-150, 130)
#> [1] 0.5798319
devig(c(-110, -250), c(-110, 200))
#> [1] 0.5000000 0.6818182
```
