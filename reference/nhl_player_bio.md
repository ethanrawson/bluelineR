# A player's bio, draft and awards

What NHL.com's player pages read now (the `v2` player API): birthplace,
nationality, size and handedness, the draft (team, round, pick, junior
club and league), every NHL award with the season, club and his numbers
that year, and the long-form bio.

## Usage

``` r
nhl_player_bio(player_id)
```

## Arguments

- player_id:

  NHL player id, e.g. `8478402`.

## Value

A list: `info` (one row) and `awards` (one row per award won).

## Examples

``` r
if (FALSE) { # interactive()
bio <- nhl_player_bio(8478402)
bio$info[, c("last_name", "birth_city", "draft_year", "draft_overall", "drafted_from_team")]
bio$awards
}
```
