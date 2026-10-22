# Draw an NHL rink

A ggplot2 rink in feet from centre ice, x along the rink (-100 to 100)
and y across it (-42.5 to 42.5), the frame the play-by-play and the
tracking use. Add layers to it like any ggplot.

## Usage

``` r
nhl_rink(ice = "#f7f9fc")
```

## Arguments

- ice:

  Fill for the ice.

## Value

A ggplot.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) nhl_rink()
```
