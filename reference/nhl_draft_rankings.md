# The draft

`nhl_draft_rankings()` is NHL Central Scouting's list for a draft
(category 1: North American skaters, 2: international skaters, 3: North
American goalies, 4: international goalies). `nhl_draft_picks()` is
every pick of a draft, or of one round.

## Usage

``` r
nhl_draft_rankings(year = NULL, category = 1)

nhl_draft_picks(year = NULL, round = "all")
```

## Arguments

- year:

  Draft year; `NULL` for the current one.

- category:

  Central Scouting category, 1 to 4.

- round:

  `"all"` or a round number.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # interactive()
nhl_draft_rankings(2026)
nhl_draft_picks(2015, round = 1)
}
```
