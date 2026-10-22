# bluelineR: Tidy Access to the NHL's Web, Stats, EDGE and Goal-Tracking APIs

bluelineR wraps the public endpoints behind NHL.com and returns tibbles
with snake_case names:

## Details

- **Games**:
  [`nhl_scores()`](https://ethanrawson.github.io/bluelineR/reference/nhl_scores.md),
  [`nhl_schedule()`](https://ethanrawson.github.io/bluelineR/reference/nhl_scores.md),
  [`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md),
  [`nhl_boxscore()`](https://ethanrawson.github.io/bluelineR/reference/nhl_boxscore.md),
  [`nhl_shifts()`](https://ethanrawson.github.io/bluelineR/reference/nhl_shifts.md),
  [`nhl_standings()`](https://ethanrawson.github.io/bluelineR/reference/nhl_standings.md).

- **Goal tracking**:
  [`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md)
  returns the puck and player positions behind every goal since 2023-24,
  ten frames a second;
  [`classify_goal()`](https://ethanrawson.github.io/bluelineR/reference/classify_goal.md)
  reads how it was scored and
  [`plot_goal()`](https://ethanrawson.github.io/bluelineR/reference/plot_goal.md)
  draws it.

- **Game tracking summaries** (2021-22 to 2023-24 and some of 2020-21
  and 2024-25):
  [`nhl_tracking_summary()`](https://ethanrawson.github.io/bluelineR/reference/nhl_tracking_summary.md)
  has each player's speed, distance, zone time and puck possession time,
  and each club's possession share.

- **NHL EDGE**:
  [`nhl_edge_skater()`](https://ethanrawson.github.io/bluelineR/reference/nhl_edge.md),
  [`nhl_edge_goalie()`](https://ethanrawson.github.io/bluelineR/reference/nhl_edge.md),
  [`nhl_edge_team()`](https://ethanrawson.github.io/bluelineR/reference/nhl_edge.md),
  [`nhl_edge_leaders()`](https://ethanrawson.github.io/bluelineR/reference/nhl_edge_leaders.md),
  [`nhl_edge_by_the_numbers()`](https://ethanrawson.github.io/bluelineR/reference/nhl_edge_by_the_numbers.md).

- **Players, teams, drafts**:
  [`nhl_player()`](https://ethanrawson.github.io/bluelineR/reference/nhl_player.md),
  [`nhl_player_game_log()`](https://ethanrawson.github.io/bluelineR/reference/nhl_player.md),
  [`nhl_player_search()`](https://ethanrawson.github.io/bluelineR/reference/nhl_player.md),
  [`nhl_roster()`](https://ethanrawson.github.io/bluelineR/reference/nhl_roster.md),
  [`nhl_team_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_team_stats.md),
  [`nhl_draft_rankings()`](https://ethanrawson.github.io/bluelineR/reference/nhl_draft_rankings.md),
  [`nhl_draft_picks()`](https://ethanrawson.github.io/bluelineR/reference/nhl_draft_rankings.md).

- **Stats and records APIs**:
  [`nhl_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stats.md),
  [`nhl_records()`](https://ethanrawson.github.io/bluelineR/reference/nhl_records.md).

- Anything else:
  [`nhl_api()`](https://ethanrawson.github.io/bluelineR/reference/nhl_api.md).

Requests are throttled and retried politely; see
[bluelineR-options](https://ethanrawson.github.io/bluelineR/reference/bluelineR-options.md).

## See also

Useful links:

- <https://github.com/ethanrawson/bluelineR>

- <https://ethanrawson.github.io/bluelineR/>

- Report bugs at <https://github.com/ethanrawson/bluelineR/issues>

## Author

**Maintainer**: Ethan Rawson <ethanb.rawson@icloud.com> \[copyright
holder\]

Authors:

- Ethan Rawson <ethanb.rawson@icloud.com> \[copyright holder\]
