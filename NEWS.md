# bluelineR (development version)

* IIHF tournaments, from the IIHF's live-data feed (`realtime.iihf.com`): `iihf_schedule()` lists a
  tournament's games (the World Championship, World Juniors, women's and under-18 Worlds and the
  divisions), `iihf_olympic_games()` every game of the 2026 Olympics, `iihf_game()` one game,
  `iihf_period_stats()` each team's shots, saves, penalty minutes, power play and faceoffs by period,
  `iihf_events()` goals with assists and strength, penalties and goalie changes, and `iihf_shots()`
  every shot with its result (goal, saved, blocked, missed) and place on the ice, from the 2019
  tournaments on. `plot_shots()` draws them, and knows the IIHF nations' colors.
* DraftKings odds and props from ESPN: `espn_odds()` (moneyline, puck line and total, opening and
  current, with no-vig chances), `espn_props()` (every player prop, over and under paired, with each
  player's NHL id), `espn_player_splits()` and `devig()`.
* `nhl_player_bio()`: the v2 player bio, with the draft and every NHL award and its season.
* `nhl_team_comparison()`, `nhl_broadcasts()` (the viewing guide), `nhl_quick_stats()` (the static
  standings, power-play and leader files at `live.nhle.com/psr`), `nhl_news()` and `nhl_videos()`
  (NHL.com's content API).
* `nhl_playoff_series()` and `nhl_playoff_games()`: a franchise's playoff record against each opponent,
  and every playoff game of any season, from records.nhl.com.
* `nhl_edge_leaders()` has all thirteen EDGE top-10 boards: skater shot location, team shot speed,
  distance, zone time and shot location, and the goalie boards (5 on 5, by area, games above .900).
* Records helpers: `nhl_franchise_records()` (each franchise's record in Game 7s, overtime, season openers,
  outdoor games, games outside North America and at other neutral sites), `nhl_draft_lottery()` (every draw
  since 1995: the pick, the clubs, the player) and `nhl_draft_lottery_odds()` (each club's chance, 1995 to
  2021), `nhl_milestones()` (players closing in on a milestone, and how far they have to go), and
  `nhl_records_catalog()`, a guide to the 78 records tables with the helper for each. `nhl_records()` takes
  `include` to join related fields such as names and team codes.
* `nhl_jersey_url()` (club jersey textures), and broadcaster logos in `nhl_broadcasts()`.
* `nhl_stat_eras()`: what the NHL kept and since when, as eras (goals and assists from 1917-18, shots and
  plus/minus from 1959-60, ice time from 1997-98, hits from 2005-06, located play-by-play from 2009-10, shift
  charts from 2010-11, tracking from 2021-22) and as each stats column's first season, measured against the
  live API. `nhl_stats()` says when it is sorting by a column the NHL did not keep for the seasons asked for,
  and `nhl_pbp()` and `nhl_shifts()` say what an old game has.
* `nhl_era_adjust()`: era-adjusted stats. Each season rescaled to one scoring environment (by default the
  last ten completed seasons, over an 82-game schedule and today's roster sizes): adjusted goals, assists and
  points for skaters, adjusted GAA and save % against the league's for goalies. `nhl_league_env()` is the
  table it reads, every completed season since 1917-18, shipped with the package.
* `nhl_player_game_log()` and `nhl_boxscore()` read seasons before 1997-98, which have no ice time (they used
  to fail on them), and `plot_shots()` says why when a game has no shot locations.
* `plot_shots()` draws each club at its own end, the away club at the left net and the home club at
  the right; `sides = "right"` keeps the old view with every shot at one net.

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
