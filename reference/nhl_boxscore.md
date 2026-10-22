# Box score

Player lines for both clubs: skaters (goals, assists, shots, hits, ice
time and more) and goalies (shots and saves by strength), plus the
teams.

## Usage

``` r
nhl_boxscore(game_id)
```

## Arguments

- game_id:

  Ten-digit NHL game id, e.g. `2025020534`.

## Value

A list of tibbles: `skaters`, `goalies` and `teams`.

## Examples

``` r
if (FALSE) { # interactive()
nhl_boxscore(2025020534)$skaters
}
```
