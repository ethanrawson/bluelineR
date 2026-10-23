# Transactions and injuries, from ESPN

- `espn_transactions()`: every NHL roster move ESPN logs in a calendar
  year: signings (with term), trades, waivers, call-ups and assignments,
  injured-reserve moves, hirings and firings. `action` is the first verb
  of the move; one entry can describe several moves.

- `espn_injuries()`: every injured player now: status, the injury, when
  it was reported and ESPN's expected return.

## Usage

``` r
espn_transactions(year = NULL)

espn_injuries()
```

## Arguments

- year:

  Calendar year; `NULL` for this year.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # interactive()
tx <- espn_transactions()
tx[tx$action == "signed", ]
espn_injuries()
}
```
