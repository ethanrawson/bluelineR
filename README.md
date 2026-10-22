
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
#> # A tibble: 11 x 5
#>           id away_team_abbrev away_team_score home_team_abbrev home_team_score
#>        <int> <chr>                      <int> <chr>                      <int>
#> 1 2026020141 SJS                            4 MTL                            3
#> 2 2026020142 COL                            3 NJD                            4
#> 3 2026020143 ANA                            2 NYI                            3
#> 4 2026020144 LAK                            5 WSH                            2
#> 5 2026020145 TOR                            6 CBJ                            2
#> # i 6 more rows
```

Play-by-play comes back one row per event, with the clock in seconds,
the strength, the players by name, the running score, and the location
turned so the shooting team always attacks to the right:

``` r
pbp <- nhl_pbp(2025020534)
pbp[pbp$type == "goal", c("period", "time_in_period", "event_team", "strength_state", "player_1_name", "x_fixed", "y_fixed")]
#> # A tibble: 4 x 7
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
#> # A tibble: 1,683 x 9
#>   frame  time entity_id is_puck player_id sweater_number team      x       y
#>   <int> <dbl>     <dbl> <lgl>       <dbl>          <dbl> <chr> <dbl>   <dbl>
#> 1     1     0         1 TRUE           NA             NA <NA>   77.9 -30.7  
#> 2     1     0      6001 FALSE     8480280              1 BOS   -87.3  -0.403
#> 3     1     0      6018 FALSE     8478401             18 BOS    81.0  -4.75 
#> 4     1     0      6028 FALSE     8477496             28 BOS    54.4  -0.288
#> 5     1     0      6039 FALSE     8479987             39 BOS    57.7  15.4  
#> # i 1,678 more rows
```

`classify_goal()` reads how it was scored. The same rules build the goal
types on BluelineMetrics, and the R port matches them goal for goal:

``` r
goal <- classify_goal(frames, team = "EDM", shot_type = "backhand")
goal[, c("shooter", "distance", "shot_speed", "since_neutral", "kinds")]
#> # A tibble: 1 x 5
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

## NHL EDGE

``` r
nhl_edge_leaders("skater_speed", season = "2025-26")[, c("rank", "player_first_name", "player_last_name", "player_team_abbrev", "max_speed_imperial", "bursts_over22")]
#> # A tibble: 10 x 6
#>    rank player_first_name player_last_name player_team_abbrev max_speed_imperial bursts_over22
#>   <int> <chr>             <chr>            <chr>                           <dbl>         <int>
#> 1     1 Beck              Malenstyn        BUF                              24.9            14
#> 2     2 Nathan            MacKinnon        COL                              24.8            45
#> 3     3 Connor            McDavid          EDM                              24.6           151
#> 4     4 Logan             Cooley           UTA                              24.4            33
#> 5     5 Jake              Sanderson        OTT                              24.4            31
#> # i 5 more rows

mcdavid <- nhl_edge_skater(8478402, "2025-26")
mcdavid$info[, c("skating_speed_speed_max_imperial", "skating_speed_speed_max_percentile", "top_shot_speed_imperial", "total_distance_skated_imperial")]
#> # A tibble: 1 x 4
#>   skating_speed_speed_max_imp~1 skating_speed_speed_~2 top_shot_speed_imper~3 total_distance_skate~4
#>                           <dbl>                  <dbl>                  <dbl>                  <dbl>
#> 1                          24.6                  0.997                   82.0                   330.
#> # i abbreviated names: 1: skating_speed_speed_max_imperial, 2: skating_speed_speed_max_percentile,
#> #   3: top_shot_speed_imperial, 4: total_distance_skated_imperial
```

## The stats API

``` r
nhl_stats("skater/summary", "2025-26", sort = "points", limit = 5)[, c("skater_full_name", "team_abbrevs", "goals", "assists", "points")]
#> # A tibble: 5 x 5
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
| Goal tracking               | `nhl_goal_tracking()`, `nhl_goal_replay()`, `goal_frame()`, `classify_goal()`, `goal_context()`, `skater_speed()`, `plot_goal()`            | `wsr.nhle.com/sprites/{season}/{game}/ev{event}.json`, `/ppt-replay/goal`                          |
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
[nhlscraper](https://cran.r-project.org/package=nhlscraper),
[hockeyR](https://cran.r-project.org/package=hockeyR) and
[fastRhockey](https://cran.r-project.org/package=fastRhockey). What it
adds is the goal tracking: the frames, the classifier and the rink
plots.
