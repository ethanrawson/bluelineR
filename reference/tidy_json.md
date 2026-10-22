# Tidy any NHL JSON

Flattens a parsed NHL response: a list of records becomes a tibble; a
record becomes a named list whose record-list parts are tibbles and
whose other fields are gathered into a one-row tibble called `info`.
Names become snake_case and localized strings keep their English text.

## Usage

``` r
tidy_json(x)
```

## Arguments

- x:

  Parsed JSON, e.g. from
  [`nhl_api()`](https://ethanrawson.github.io/bluelineR/reference/nhl_api.md).

## Value

A tibble or a named list of tibbles.

## Examples

``` r
tidy_json(list(list(playerId = 1, firstName = list(default = "Connor"))))
#> # A tibble: 1 × 2
#>   player_id first_name
#>       <dbl> <chr>     
#> 1         1 Connor    
```
