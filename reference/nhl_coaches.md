# Coaches and general managers

Every NHL head coach and general manager, from records.nhl.com:

## Usage

``` r
nhl_coaches(
  by = c("career", "team", "bio"),
  game_type = "regular",
  active = NULL
)

nhl_general_managers(
  by = c("career", "team", "bio"),
  game_type = "regular",
  active = NULL
)
```

## Arguments

- by:

  `"career"`, `"team"` or `"bio"`.

- game_type:

  `"regular"` or `"playoffs"` (not used for `"bio"`).

- active:

  `TRUE` for those in the job now (by `"team"`, just the club each has
  now), `FALSE` for the rest, `NULL` for everyone.

## Value

A tibble, the winningest first (bios by name).

## Details

- `by = "career"`: each one's whole NHL career: seasons, clubs, games,
  wins, losses, ties and overtime losses, win percentage, Stanley Cups
  and Cup Final appearances, and the Jack Adams (coaches) or GM of the
  Year awards.

- `by = "team"`: the same, with each club he coached or ran, with the
  dates (a GM's are the day he was hired and the day he left).

- `by = "bio"`: where and when he was born, his nationality, the Hockey
  Hall of Fame, and his NHL player id if he played (`player_id`, for
  [`nhl_player()`](https://ethanrawson.github.io/bluelineR/reference/nhl_player.md));
  for GMs the record's own notes on each hiring and firing.

## Examples

``` r
if (FALSE) { # interactive()
nhl_coaches()
nhl_coaches("team", active = TRUE)
nhl_coaches("career", "playoffs")[, c("name", "games", "wins", "stanley_cups")]
nhl_general_managers("team", active = TRUE)
nhl_general_managers("bio")
}
```
