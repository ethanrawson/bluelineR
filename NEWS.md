# bluelineR (development version)

* `nhl_international()`, `nhl_international_careers()`, `nhl_international_games()`,
  `nhl_international_winners()` and `nhl_olympic_podiums()`: every Canada Cup, World Cup of Hockey,
  Olympics and 4 Nations Face-Off with NHL players, from records.nhl.com.
* `animate_goal()` puts GOAL in the middle of the rink and labels overtime goals OT.
* Goal plots and videos use national colors for the 4 Nations Face-Off, whose goals are tracked.
* `animate_goal(logos = TRUE)` puts the clubs' logos in the title and the home club's at centre ice, or
  any SVG or PNG with `centre_logo`; `nhl_goal_replay()` has the logos' addresses. "GOAL" now flashes on
  a scoreboard panel.
* `animate_goal()` writes a goal's tracking replay as an MP4: every player and the puck on the rink,
  sweater numbers in club colors, the puck's trail, the scorer and his assists named, his skating speed,
  and the last three seconds again at half speed.
* `nhl_tracking_summary()`, `nhl_tracking_player_stats()` and `nhl_tracking_entities()` read the game
  tracking files at `live.nhle.com/ppt`: each player's speed, distance, zone time, zone starts and puck
  possession time, each club's possession by zone and strength, ice time by strength and every shift.

# bluelineR 0.1.0

* First release: scores, schedules, standings, play-by-play, box scores and shift charts; players,
  rosters, prospects, club stats, stat leaders and the draft; the stats and records APIs; NHL EDGE
  (skater, goalie and team reports, leaderboards, last night's standouts); and goal tracking frames
  with `goal_frame()`, `classify_goal()`, `goal_context()`, `skater_speed()` and rink plots.
