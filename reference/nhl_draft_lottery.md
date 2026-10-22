# Draft lottery winners and odds

`nhl_draft_lottery()` is every lottery draw since 1995: the pick it won,
the club whose pick moved, the club that made the pick (they differ when
the pick had been traded), the player taken and how far the pick moved.
`nhl_draft_lottery_odds()` is each club's chance going in. The NHL
published the odds as a table through 2021; for later years it posted an
image, and the function says where it is.

## Usage

``` r
nhl_draft_lottery(year = NULL)

nhl_draft_lottery_odds(year)
```

## Arguments

- year:

  Draft year; `NULL` for every year.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # interactive()
nhl_draft_lottery(2026)
nhl_draft_lottery_odds(2016)
}
```
