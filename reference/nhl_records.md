# The NHL records API

records.nhl.com: franchise and player records, every draft pick ever,
officials, coaches' careers and more. `resource` is the API's name for a
table (`"officials"`, `"coach-career-records"`, `"draft"`,
`"franchise-team-totals"`, `"player"`,
`"skater-career-scoring-regular-season"`, ...).

## Usage

``` r
nhl_records(resource, filter = NULL, limit = NULL)
```

## Arguments

- resource:

  The table.

- filter:

  A Cayenne expression, e.g. `"draftYear=2015"`.

- limit:

  Rows to return; `NULL` for the API's default.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # interactive()
nhl_records("officials")
nhl_records("draft", filter = "draftYear=2015 and roundNumber=1")
}
```
