# IIHF games: schedules, shot locations, goals and penalties

The IIHF's live-data feed (`realtime.iihf.com`, the one behind the game
centre on iihf.com) has every game of its championships: the World
Championship, the World Juniors, the women's and under-18 Worlds and the
division tournaments, and the 2026 Olympics. For each game it has the
score by period, the team stats, every goal with its scorer, assists and
strength, every penalty and goalie change, and **every shot with a place
on the ice**: goals, saves, blocked shots and shots that missed the net.
Shot locations go back to the 2019 tournaments; older games have the
rest.

## Usage

``` r
iihf_schedule(year, event = "wm")

iihf_olympic_games()

iihf_game(game_id)

iihf_period_stats(game_id)

iihf_shots(game_id, length = 200, width = 85)

iihf_events(game_id)
```

## Arguments

- year:

  Year the tournament was played (the World Juniors that ran from
  December 2025 into January 2026 are `2026`).

- event:

  The tournament's code in iihf.com addresses: `"wm"` World
  Championship, `"wm20"` World Juniors, `"ww"` Women's World
  Championship, `"wm18"` and `"ww18"` the under-18s, and the divisions
  (`"wm20ia"`, `"wmia"`, ...).

- game_id:

  IIHF game id, from `iihf_schedule()` or `iihf_olympic_games()`; the
  2026 Olympic gold medal game is `1010000058`.

- length, width:

  Rink length and width in feet, for `x` and `y`.

## Value

A tibble.

## Details

- `iihf_schedule()`: a tournament's games, with the ids the others take.

- `iihf_olympic_games()`: every game of the 2026 Olympics, men's and
  women's (the Olympics are not on the IIHF's schedule pages).

- `iihf_game()`: one game in a row: teams, final score, venue, date,
  attendance and how it ended.

- `iihf_period_stats()`: shots on goal, saves, penalty minutes,
  power-play time and goals and faceoffs won, for each team in each
  period.

- `iihf_shots()`: every shot, its result, who took it, and where.

- `iihf_events()`: goals, penalties and goalie changes in order.

**Where shots are.** The feed places each shot on a 0-1 scale of the
rink (`x_raw` along it, `y_raw` across). `x` and `y` scale that to feet
from centre ice on a rink `length` by `width` (an NHL rink by default,
which is what the 2026 Olympics used; IIHF rinks can be up to 60 m by 30
m), the frame
[`nhl_rink()`](https://ethanrawson.github.io/bluelineR/reference/nhl_rink.md)
draws. Teams change ends between periods, so `x_fixed` and `y_fixed`
turn every shot so its team attacks to the right (each team's direction
in a period is the end most of its shots were taken at), and `distance`
(feet) and `angle` (degrees off the middle) are measured to the net it
attacked. The table works with
[`plot_shots()`](https://ethanrawson.github.io/bluelineR/reference/plot_shots.md).

Shot results are the feed's: `"G"` goal, `"SSG"` saved by the
goalkeeper, `"SSP"` saved by a player (a blocked shot, placed where it
was taken) and `"SPG"` past the goal (missed the net). The feed times
goals only, so the other shots have their period but no clock.

iihf.com itself refuses scripted requests; `iihf_schedule()` reads the
same pages from its mirror at `canada-central.iihf.com`.

## Examples

``` r
if (FALSE) { # interactive()
# The 2026 Olympic final: Jack Hughes in overtime.
shots <- iihf_shots(1010000058)
shots[shots$result == "goal", c("period", "time", "team", "player_name", "x", "y", "distance")]
plot_shots(shots)
iihf_events(1010000058)

# The 2026 World Championship, and every shot of its opening game:
games <- iihf_schedule(2026, "wm")
iihf_shots(games$game_id[1])

# Every game of the 2026 Olympics:
iihf_olympic_games()
}
```
