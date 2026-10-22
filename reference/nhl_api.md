# Call any NHL endpoint

The escape hatch: a GET against one of the NHL's APIs, returned as
parsed JSON (nested lists). Every other function in the package is built
on it.

## Usage

``` r
nhl_api(
  path,
  api = c("web", "stats", "records", "search"),
  query = list(),
  tidy = FALSE
)
```

## Arguments

- path:

  Path below the API's base URL, e.g. `"score/now"`.

- api:

  Which API: `"web"` (`api-web.nhle.com/v1`), `"stats"`
  (`api.nhle.com/stats/rest/en`), `"records"`
  (`records.nhl.com/site/api`) or `"search"`
  (`search.d3.nhle.com/api/v1`).

- query:

  Named list of query parameters.

- tidy:

  If `TRUE`, the result goes through
  [`tidy_json()`](https://ethanrawson.github.io/bluelineR/reference/tidy_json.md).

## Value

The parsed response.

## Examples

``` r
if (FALSE) { # interactive()
nhl_api("partner-game/US/now")
nhl_api("glossary", api = "stats", tidy = TRUE)
}
```
