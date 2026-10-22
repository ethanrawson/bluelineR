# Changelog

## bluelineR (development version)

- [`nhl_international()`](https://ethanrawson.github.io/bluelineR/reference/nhl_international.md),
  [`nhl_international_careers()`](https://ethanrawson.github.io/bluelineR/reference/nhl_international.md),
  [`nhl_international_games()`](https://ethanrawson.github.io/bluelineR/reference/nhl_international.md),
  [`nhl_international_winners()`](https://ethanrawson.github.io/bluelineR/reference/nhl_international.md)
  and
  [`nhl_olympic_podiums()`](https://ethanrawson.github.io/bluelineR/reference/nhl_international.md):
  every Canada Cup, World Cup of Hockey, Olympics and 4 Nations Face-Off
  with NHL players, from records.nhl.com.
- [`animate_goal()`](https://ethanrawson.github.io/bluelineR/reference/animate_goal.md)
  puts GOAL in the middle of the rink and labels overtime goals OT.
- Goal plots and videos use national colors for the 4 Nations Face-Off,
  whose goals are tracked.
- [`animate_goal()`](https://ethanrawson.github.io/bluelineR/reference/animate_goal.md)
  writes a goal’s tracking replay as an MP4: every player and the puck
  on the rink, sweater numbers in club colors, the puck’s trail, the
  scorer and his assists named, his skating speed, and the last three
  seconds again at half speed.
- [`nhl_tracking_summary()`](https://ethanrawson.github.io/bluelineR/reference/nhl_tracking_summary.md),
  [`nhl_tracking_player_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_tracking_summary.md)
  and
  [`nhl_tracking_entities()`](https://ethanrawson.github.io/bluelineR/reference/nhl_tracking_summary.md)
  read the game tracking files at `live.nhle.com/ppt`: each player’s
  speed, distance, zone time, zone starts and puck possession time, each
  club’s possession by zone and strength, ice time by strength and every
  shift.

## bluelineR 0.1.0

- First release: scores, schedules, standings, play-by-play, box scores
  and shift charts; players, rosters, prospects, club stats, stat
  leaders and the draft; the stats and records APIs; NHL EDGE (skater,
  goalie and team reports, leaderboards, last night’s standouts); and
  goal tracking frames with
  [`goal_frame()`](https://ethanrawson.github.io/bluelineR/reference/goal_frame.md),
  [`classify_goal()`](https://ethanrawson.github.io/bluelineR/reference/classify_goal.md),
  [`goal_context()`](https://ethanrawson.github.io/bluelineR/reference/goal_context.md),
  [`skater_speed()`](https://ethanrawson.github.io/bluelineR/reference/skater_speed.md)
  and rink plots.
