# Milestones in sight

The NHL's milestone tracker: players closing in on a round number of
games, goals, assists or points (skaters) or games, wins, shutouts or
minutes (goalies), in the regular season or the playoffs, with how many
they have and how many they still need. A player who has just reached
one stays on the list for a while; his `to_go` is zero or less and he
sorts after the milestones still to come.

## Usage

``` r
nhl_milestones(type = c("skater", "goalie"))
```

## Arguments

- type:

  `"skater"` or `"goalie"`.

## Value

A tibble, the nearest milestones first.

## Examples

``` r
if (FALSE) { # interactive()
nhl_milestones()
nhl_milestones("goalie")
}
```
