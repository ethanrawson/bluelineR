# Changelog

## bluelineR 0.2.0

- Contracts and trades from Sportsnet’s stats API (PuckPedia’s data):
  [`nhl_signings()`](https://ethanrawson.github.io/bluelineR/reference/nhl_signings.md)
  (every contract signed in a year, and with `by_season = TRUE` each
  season’s cap hit, salary, bonuses and clause) and
  [`nhl_trades()`](https://ethanrawson.github.io/bluelineR/reference/nhl_signings.md)
  (every trade since 2020-21, or every player and pick moved, with cap
  hits and retained salary). From ESPN,
  [`espn_transactions()`](https://ethanrawson.github.io/bluelineR/reference/espn_transactions.md)
  (every roster move) and
  [`espn_injuries()`](https://ethanrawson.github.io/bluelineR/reference/espn_transactions.md).

- [`nhl_coaches()`](https://ethanrawson.github.io/bluelineR/reference/nhl_coaches.md)
  and
  [`nhl_general_managers()`](https://ethanrawson.github.io/bluelineR/reference/nhl_coaches.md):
  every head coach and GM, by career, by club or as a bio, from
  records.nhl.com.

- IIHF tournaments, from the IIHF’s live-data feed
  (`realtime.iihf.com`):
  [`iihf_schedule()`](https://ethanrawson.github.io/bluelineR/reference/iihf.md)
  lists a tournament’s games (the World Championship, World Juniors,
  women’s and under-18 Worlds and the divisions),
  [`iihf_olympic_games()`](https://ethanrawson.github.io/bluelineR/reference/iihf.md)
  every game of the 2026 Olympics,
  [`iihf_game()`](https://ethanrawson.github.io/bluelineR/reference/iihf.md)
  one game,
  [`iihf_period_stats()`](https://ethanrawson.github.io/bluelineR/reference/iihf.md)
  each team’s shots, saves, penalty minutes, power play and faceoffs by
  period,
  [`iihf_events()`](https://ethanrawson.github.io/bluelineR/reference/iihf.md)
  goals with assists and strength, penalties and goalie changes, and
  [`iihf_shots()`](https://ethanrawson.github.io/bluelineR/reference/iihf.md)
  every shot with its result (goal, saved, blocked, missed) and place on
  the ice, from the 2019 tournaments on.
  [`plot_shots()`](https://ethanrawson.github.io/bluelineR/reference/plot_shots.md)
  draws them, and knows the IIHF nations’ colors.

- DraftKings odds and props from ESPN:
  [`espn_odds()`](https://ethanrawson.github.io/bluelineR/reference/espn_odds.md)
  (moneyline, puck line and total, opening and current, with no-vig
  chances),
  [`espn_props()`](https://ethanrawson.github.io/bluelineR/reference/espn_odds.md)
  (every player prop, over and under paired, with each player’s NHL id),
  [`espn_player_splits()`](https://ethanrawson.github.io/bluelineR/reference/espn_player_splits.md)
  and
  [`devig()`](https://ethanrawson.github.io/bluelineR/reference/devig.md).

- [`nhl_player_bio()`](https://ethanrawson.github.io/bluelineR/reference/nhl_player_bio.md):
  the v2 player bio, with the draft and every NHL award and its season.

- [`nhl_team_comparison()`](https://ethanrawson.github.io/bluelineR/reference/nhl_team_comparison.md),
  [`nhl_broadcasts()`](https://ethanrawson.github.io/bluelineR/reference/nhl_broadcasts.md)
  (the viewing guide),
  [`nhl_quick_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_quick_stats.md)
  (the static standings, power-play and leader files at
  `live.nhle.com/psr`),
  [`nhl_news()`](https://ethanrawson.github.io/bluelineR/reference/nhl_news.md)
  and
  [`nhl_videos()`](https://ethanrawson.github.io/bluelineR/reference/nhl_news.md)
  (NHL.com’s content API).

- [`nhl_playoff_series()`](https://ethanrawson.github.io/bluelineR/reference/nhl_playoff_series.md)
  and
  [`nhl_playoff_games()`](https://ethanrawson.github.io/bluelineR/reference/nhl_playoff_series.md):
  a franchise’s playoff record against each opponent, and every playoff
  game of any season, from records.nhl.com.

- [`nhl_edge_leaders()`](https://ethanrawson.github.io/bluelineR/reference/nhl_edge_leaders.md)
  has all thirteen EDGE top-10 boards: skater shot location, team shot
  speed, distance, zone time and shot location, and the goalie boards (5
  on 5, by area, games above .900).

- Records helpers:
  [`nhl_franchise_records()`](https://ethanrawson.github.io/bluelineR/reference/nhl_franchise_records.md)
  (each franchise’s record in Game 7s, overtime, season openers, outdoor
  games, games outside North America and at other neutral sites),
  [`nhl_draft_lottery()`](https://ethanrawson.github.io/bluelineR/reference/nhl_draft_lottery.md)
  (every draw since 1995: the pick, the clubs, the player) and
  [`nhl_draft_lottery_odds()`](https://ethanrawson.github.io/bluelineR/reference/nhl_draft_lottery.md)
  (each club’s chance, 1995 to 2021),
  [`nhl_milestones()`](https://ethanrawson.github.io/bluelineR/reference/nhl_milestones.md)
  (players closing in on a milestone, and how far they have to go), and
  [`nhl_records_catalog()`](https://ethanrawson.github.io/bluelineR/reference/nhl_records_catalog.md),
  a guide to the 78 records tables with the helper for each.
  [`nhl_records()`](https://ethanrawson.github.io/bluelineR/reference/nhl_records.md)
  takes `include` to join related fields such as names and team codes.

- [`nhl_jersey_url()`](https://ethanrawson.github.io/bluelineR/reference/nhl_headshot_url.md)
  (club jersey textures), and broadcaster logos in
  [`nhl_broadcasts()`](https://ethanrawson.github.io/bluelineR/reference/nhl_broadcasts.md).

- [`nhl_stat_eras()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stat_eras.md):
  what the NHL kept and since when, as eras (goals and assists from
  1917-18, shots and plus/minus from 1959-60, ice time from 1997-98,
  hits from 2005-06, located play-by-play from 2009-10, shift charts
  from 2010-11, tracking from 2021-22) and as each stats column’s first
  season, measured against the live API.
  [`nhl_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stats.md)
  says when it is sorting by a column the NHL did not keep for the
  seasons asked for, and
  [`nhl_pbp()`](https://ethanrawson.github.io/bluelineR/reference/nhl_pbp.md)
  and
  [`nhl_shifts()`](https://ethanrawson.github.io/bluelineR/reference/nhl_shifts.md)
  say what an old game has.

- [`nhl_era_adjust()`](https://ethanrawson.github.io/bluelineR/reference/nhl_era_adjust.md):
  era-adjusted stats. Each season rescaled to one scoring environment
  (by default the last ten completed seasons, over an 82-game schedule
  and today’s roster sizes): adjusted goals, assists and points for
  skaters, adjusted GAA and save % against the league’s for goalies.
  [`nhl_league_env()`](https://ethanrawson.github.io/bluelineR/reference/nhl_league_env.md)
  is the table it reads, every completed season since 1917-18, shipped
  with the package.

- [`nhl_player_game_log()`](https://ethanrawson.github.io/bluelineR/reference/nhl_player.md)
  and
  [`nhl_boxscore()`](https://ethanrawson.github.io/bluelineR/reference/nhl_boxscore.md)
  read seasons before 1997-98, which have no ice time (they used to fail
  on them), and
  [`plot_shots()`](https://ethanrawson.github.io/bluelineR/reference/plot_shots.md)
  says why when a game has no shot locations.

- [`plot_shots()`](https://ethanrawson.github.io/bluelineR/reference/plot_shots.md)
  draws each club at its own end, the away club at the left net and the
  home club at the right; `sides = "right"` keeps the old view with
  every shot at one net.

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

- `animate_goal(logos = TRUE)` puts the clubs’ logos in the title and
  the home club’s at centre ice, or any SVG or PNG with `centre_logo`;
  [`nhl_goal_replay()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md)
  has the logos’ addresses. “GOAL” now flashes on a scoreboard panel.

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
