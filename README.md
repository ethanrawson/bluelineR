
# bluelineR <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/ethanrawson/bluelineR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ethanrawson/bluelineR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/ethanrawson/bluelineR/actions/workflows/pkgdown.yaml/badge.svg)](https://ethanrawson.github.io/bluelineR/)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
<!-- badges: end -->

bluelineR wraps the public APIs behind NHL.com and returns tidy tibbles:
scores, schedules, standings, play-by-play, box scores and shift charts;
players, rosters, stat leaders and the draft; the stats and records
APIs; **NHL EDGE** skating, shot and zone-time tracking; and the **puck
and player tracking frames behind every goal since 2023-24**, ten frames
a second, with tools that read how each goal was scored and draw it on a
rink.

It grew out of [BluelineMetrics](https://bluelinemetrics.com), where
these endpoints feed the live game tracker, the goal replays and the
player pages.

## Installation

``` r
# install.packages("pak")
pak::pak("ethanrawson/bluelineR")
```

## A game

``` r
library(bluelineR)

nhl_scores("2026-10-20")[, c("id", "away_team_abbrev", "away_team_score", "home_team_abbrev", "home_team_score")]
#> # A tibble: 11 × 5
#>           id away_team_abbrev away_team_score home_team_abbrev home_team_score
#>        <int> <chr>                      <int> <chr>                      <int>
#> 1 2026020141 SJS                            4 MTL                            3
#> 2 2026020142 COL                            3 NJD                            4
#> 3 2026020143 ANA                            2 NYI                            3
#> 4 2026020144 LAK                            5 WSH                            2
#> 5 2026020145 TOR                            6 CBJ                            2
#> # ℹ 6 more rows
```

Play-by-play comes back one row per event, with the clock in seconds,
the strength, the players by name, the running score, and the location
turned so the shooting team always attacks to the right:

``` r
pbp <- nhl_pbp(2025020534)
pbp[pbp$type == "goal", c("period", "time_in_period", "event_team", "strength_state", "player_1_name", "x_fixed", "y_fixed")]
#> # A tibble: 4 × 7
#>   period time_in_period event_team strength_state player_1_name       x_fixed y_fixed
#>    <int> <chr>          <chr>      <chr>          <chr>                 <dbl>   <dbl>
#> 1      1 13:38          EDM        5v4            Ryan Nugent-Hopkins      44      -6
#> 2      1 16:27          BOS        5v4            Pavel Zacha              82      -3
#> 3      2 14:38          EDM        5v5            Quinn Hutson             83       6
#> 4      3 01:41          EDM        4v5            Connor McDavid           87      -3
```

``` r
plot_shots(pbp)
```

<img src="man/figures/README-shots-1.png" alt="Shot map of Edmonton at Boston, both clubs attacking right." width="100%" />

## A goal, from the tracking

The NHL keeps about fourteen seconds of tracking behind every goal.
`nhl_goal_tracking()` fetches it (the files only answer requests that
come from nhl.com, so it says it does) as one row per skater, goalie and
puck per frame, in feet:

``` r
frames <- nhl_goal_tracking(2025020534, 777)
frames
#> # A tibble: 1,683 × 9
#>   frame  time entity_id is_puck player_id sweater_number team      x       y
#>   <int> <dbl>     <dbl> <lgl>       <dbl>          <dbl> <chr> <dbl>   <dbl>
#> 1     1     0         1 TRUE           NA             NA <NA>   77.9 -30.7  
#> 2     1     0      6001 FALSE     8480280              1 BOS   -87.3  -0.403
#> 3     1     0      6018 FALSE     8478401             18 BOS    81.0  -4.75 
#> 4     1     0      6028 FALSE     8477496             28 BOS    54.4  -0.288
#> 5     1     0      6039 FALSE     8479987             39 BOS    57.7  15.4  
#> # ℹ 1,678 more rows
```

`classify_goal()` reads how it was scored. The same rules build the goal
types on BluelineMetrics, and the R port matches them goal for goal:

``` r
goal <- classify_goal(frames, team = "EDM", shot_type = "backhand")
goal[, c("shooter", "distance", "shot_speed", "since_neutral", "kinds")]
#> # A tibble: 1 × 5
#>   shooter distance shot_speed since_neutral kinds          
#>     <dbl>    <dbl>      <dbl>         <dbl> <chr>          
#> 1 8478402      7.5       24.1           2.8 rush, breakaway
```

``` r
plot_goal(frames, title = "Connor McDavid, shorthanded breakaway at Boston, 18 Dec 2025")
```

<img src="man/figures/README-goal-1.png" alt="McDavid's shorthanded breakaway goal at Boston drawn from tracking: every player's position as the puck goes in, with the last two seconds of each path." width="100%" />

``` r
plot_goal_sequence(frames, n = 6, seconds = 5)
```

<img src="man/figures/README-sequence-1.png" alt="Six frames leading up to the goal." width="100%" />

`animate_goal()` plays it back as an MP4: every player and the puck, the scorer and his assists named,
his skating speed, and the last three seconds again at half speed (it needs the
[av](https://docs.ropensci.org/av/) package).

``` r
animate_goal(frames, "mcdavid.mp4", goal = nhl_goal_replay(2025020534, 777))
```

<img src="man/figures/README-animate.gif" alt="McDavid's goal played back from the tracking: Boston's players in gold and Edmonton's in navy move up the ice, McDavid's speed shows above him, GOAL flashes as the puck goes in, and the last three seconds replay at half speed." width="100%" />

## Game tracking summaries

For 2021-22 to 2023-24 (and some of 2020-21 and 2024-25) the NHL’s
tracking vendor left a summary of every game: each player’s skating
speed, distance, zone time and zone starts, and **his puck possession
time**, in all, by zone and by strength, with each club’s possession
share. Individual possession is not in NHL EDGE.

``` r
tr <- nhl_tracking_summary(2023020500)
tr$teams[, c("team", "possession_pct", "possession_pct_o_zone", "possession_pct_d_zone")]
#> # A tibble: 2 × 4
#>   team  possession_pct possession_pct_o_zone possession_pct_d_zone
#>   <chr>          <dbl>                 <dbl>                 <dbl>
#> 1 FLA             51.5                  45.4                  34.4
#> 2 STL             48.5                  38.4                  42.0
top <- tr$players[order(-tr$players$possession_time), ]
top[, c("name", "team", "time_on_total", "possession_time", "possession_time_o_zone", "speed_max_mph", "distance_miles")]
#> # A tibble: 40 × 7
#>   name       team  time_on_total possession_time possession_time_o_zone speed_max_mph distance_miles
#>   <chr>      <chr>         <int>           <int>                  <int>         <dbl>          <dbl>
#> 1 Colton Pa… STL            1339              61                      5          20.7           3.28
#> 2 Brandon M… FLA            1704              57                     15          20.9           3.64
#> 3 Aaron Ekb… FLA             899              54                      8          20.2           3.27
#> 4 Jordan Ky… STL             960              48                     25          20.9           2.93
#> 5 Sam Reinh… FLA             759              45                     18          20.7           2.99
#> # ℹ 35 more rows
```

## NHL EDGE

``` r
nhl_edge_leaders("skater_speed", season = "2025-26")[, c("rank", "player_first_name", "player_last_name", "player_team_abbrev", "max_speed_imperial", "bursts_over22")]
#> # A tibble: 10 × 6
#>    rank player_first_name player_last_name player_team_abbrev max_speed_imperial bursts_over22
#>   <int> <chr>             <chr>            <chr>                           <dbl>         <int>
#> 1     1 Beck              Malenstyn        BUF                              24.9            14
#> 2     2 Nathan            MacKinnon        COL                              24.8            45
#> 3     3 Connor            McDavid          EDM                              24.6           151
#> 4     4 Logan             Cooley           UTA                              24.4            33
#> 5     5 Jake              Sanderson        OTT                              24.4            31
#> # ℹ 5 more rows

mcdavid <- nhl_edge_skater(8478402, "2025-26")
mcdavid$info[, c("skating_speed_speed_max_imperial", "skating_speed_speed_max_percentile", "top_shot_speed_imperial", "total_distance_skated_imperial")]
#> # A tibble: 1 × 4
#>   skating_speed_speed_max_imp…¹ skating_speed_speed_…² top_shot_speed_imper…³ total_distance_skate…⁴
#>                           <dbl>                  <dbl>                  <dbl>                  <dbl>
#> 1                          24.6                  0.997                   82.0                   330.
#> # ℹ abbreviated names: ¹​skating_speed_speed_max_imperial, ²​skating_speed_speed_max_percentile,
#> #   ³​top_shot_speed_imperial, ⁴​total_distance_skated_imperial
```

## The stats API

``` r
nhl_stats("skater/summary", "2025-26", sort = "points", limit = 5)[, c("skater_full_name", "team_abbrevs", "goals", "assists", "points")]
#> # A tibble: 5 × 5
#>   skater_full_name  team_abbrevs goals assists points
#>   <chr>             <chr>        <int>   <int>  <int>
#> 1 Connor McDavid    EDM             48      90    138
#> 2 Nikita Kucherov   TBL             44      86    130
#> 3 Nathan MacKinnon  COL             53      74    127
#> 4 Macklin Celebrini SJS             45      70    115
#> 5 Mark Scheifele    WPG             36      67    103
```

## What it covers

| Area                        | Functions                                                                                                                                   | Endpoint                                                                                           |
|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| Scores, schedule, standings | `nhl_scores()`, `nhl_schedule()`, `nhl_team_schedule()`, `nhl_standings()`                                                                  | `api-web.nhle.com/v1/score`, `/schedule`, `/club-schedule-season`, `/standings`                    |
| Games                       | `nhl_pbp()`, `nhl_boxscore()`, `nhl_game()`, `nhl_shifts()`                                                                                 | `/gamecenter/{id}/play-by-play`, `/boxscore`, `/landing`; `api.nhle.com/stats/rest/en/shiftcharts` |
| Goal tracking               | `nhl_goal_tracking()`, `nhl_goal_replay()`, `goal_frame()`, `classify_goal()`, `goal_context()`, `skater_speed()`, `plot_goal()`, `animate_goal()`            | `wsr.nhle.com/sprites/{season}/{game}/ev{event}.json`, `/ppt-replay/goal`                          |
| Game tracking summaries     | `nhl_tracking_summary()`, `nhl_tracking_player_stats()`, `nhl_tracking_entities()`                                                          | `live.nhle.com/ppt/{season}/{game}/` (2021-22 to 2023-24, some of 2020-21 and 2024-25)             |
| NHL EDGE                    | `nhl_edge_skater()`, `nhl_edge_goalie()`, `nhl_edge_team()`, `nhl_edge_leaders()`, `nhl_edge_landing()`, `nhl_edge_by_the_numbers()`        | `/edge/...` (20 reports)                                                                           |
| Players and clubs           | `nhl_player()`, `nhl_player_game_log()`, `nhl_player_search()`, `nhl_roster()`, `nhl_prospects()`, `nhl_team_stats()`, `nhl_stat_leaders()` | `/player`, `/roster`, `/prospects`, `/club-stats`, `/skater-stats-leaders`; `search.d3.nhle.com`   |
| Draft                       | `nhl_draft_rankings()`, `nhl_draft_picks()`                                                                                                 | `/draft/rankings`, `/draft/picks`                                                                  |
| Stats and records APIs      | `nhl_stats()`, `nhl_stats_reports()`, `nhl_teams()`, `nhl_seasons()`, `nhl_franchises()`, `nhl_records()`                                   | `api.nhle.com/stats/rest/en`, `records.nhl.com/site/api`                                           |
| Anything else               | `nhl_api()`, `tidy_json()`                                                                                                                  | any of the above                                                                                   |

## Being a good guest

These are the NHL’s own, undocumented APIs; bluelineR is not affiliated
with the NHL, and endpoints can change without notice. Requests are
throttled (five a second by default) and retried with backoff on rate
limits; turn on `options(bluelineR.cache = TRUE)` to keep responses for
the session.

bluelineR stands on the work of other R hockey packages, notably
[nhlscraper](https://rentosaijo.github.io/nhlscraper/),
[hockeyR](https://cran.r-project.org/package=hockeyR) and
[fastRhockey](https://cran.r-project.org/package=fastRhockey). nhlscraper was first to the goal tracking
frames: its `replay()` has read them from `wsr.nhle.com` since November 2025, and `replays()` serves a
season of them at once. What bluelineR adds:

* **Game tracking summaries** (`nhl_tracking_summary()`): each player's puck possession time, by zone
  and strength, with speed, distance, zone time and zone starts, and each club's possession share, from
  the per-game files at `live.nhle.com/ppt`.
* **Reading a goal from its tracking** (`classify_goal()`): rush, breakaway, odd-man rush, one-timer,
  cross-slot pass, traffic, behind the net and the forecheck, with who carried it in and who made the
  pass, and the frame the puck went in (`goal_frame()`).
* **Goal replays as video** (`animate_goal()`): the tracking played back on a rink as an MP4, with
  the scorer and his assists named, his skating speed and the finish again in slow motion.
* **NHL EDGE** leaderboards, comparison reports and last night's standouts, the goal replay summary
  (`nhl_goal_replay()`) and player search.
