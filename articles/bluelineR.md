# Getting started with bluelineR

``` r

library(bluelineR)
```

## A night of hockey

``` r

scores <- nhl_scores("2026-10-20")
scores[, c("id", "away_team_abbrev", "away_team_score", "home_team_abbrev", "home_team_score", "game_outcome_last_period_type")]
#> # A tibble: 11 × 6
#>            id away_team_abbrev away_team_score home_team_abbrev home_team_score
#>         <int> <chr>                      <int> <chr>                      <int>
#>  1 2026020141 SJS                            4 MTL                            3
#>  2 2026020142 COL                            3 NJD                            4
#>  3 2026020143 ANA                            2 NYI                            3
#>  4 2026020144 LAK                            5 WSH                            2
#>  5 2026020145 TOR                            6 CBJ                            2
#>  6 2026020146 WPG                            1 STL                            2
#>  7 2026020147 BOS                            2 DAL                            3
#>  8 2026020148 MIN                            3 EDM                            4
#>  9 2026020149 DET                            3 SEA                            4
#> 10 2026020150 CAR                            6 VAN                            3
#> 11 2026020151 TBL                            6 VGK                            2
#> # ℹ 1 more variable: game_outcome_last_period_type <chr>
```

`id` is the game id every game function takes.

## One game

``` r

pbp <- nhl_pbp(2025020534)
table(pbp$type)
#> 
#> blocked-shot      faceoff     game-end     giveaway         goal          hit 
#>           32           63            1           30            4           43 
#>  missed-shot      penalty   period-end period-start shot-on-goal     stoppage 
#>           21            9            3            3           47           51 
#>     takeaway 
#>            8
```

Each event has the clock (`period_seconds`, `game_seconds`), the
strength from the event team’s side (`strength_state`, e.g. `"5v4"`),
the players by id and name, the running score, and the location twice:
as the feed gives it (`x`, `y`) and turned so the event team attacks
right (`x_fixed`, `y_fixed`).

``` r

plot_shots(pbp)
```

![Shot map, both clubs attacking
right.](bluelineR_files/figure-html/unnamed-chunk-5-1.png)

``` r

box <- nhl_boxscore(2025020534)
box$skaters[order(-box$skaters$toi_seconds), c("team", "name", "position", "goals", "assists", "sog", "toi")]
#> # A tibble: 36 × 7
#>   team  name         position goals assists   sog toi  
#>   <chr> <chr>        <chr>    <int>   <int> <int> <chr>
#> 1 BOS   H. Lindholm  D            0       0     3 25:10
#> 2 EDM   E. Bouchard  D            0       0     2 25:09
#> 3 BOS   C. McAvoy    D            0       1     3 23:21
#> 4 EDM   C. McDavid   C            1       1     3 22:56
#> 5 EDM   L. Draisaitl C            0       1     4 22:50
#> # ℹ 31 more rows

shifts <- nhl_shifts(2025020534)
head(shifts[, c("team_abbrev", "player_name", "period", "start_time", "end_time", "duration_seconds")])
#> # A tibble: 6 × 6
#>   team_abbrev player_name period start_time end_time duration_seconds
#>   <chr>       <chr>        <int> <chr>      <chr>               <dbl>
#> 1 BOS         Sean Kuraly      1 02:46      03:28                  42
#> 2 BOS         Sean Kuraly      1 05:14      06:02                  48
#> 3 BOS         Sean Kuraly      1 08:15      08:53                  38
#> 4 BOS         Sean Kuraly      1 12:49      13:38                  49
#> 5 BOS         Sean Kuraly      1 14:56      15:45                  49
#> 6 BOS         Sean Kuraly      1 17:44      18:38                  54
```

## Every goal’s tracking

``` r

goals <- pbp[pbp$type == "goal", ]
kinds <- do.call(rbind, lapply(seq_len(nrow(goals)), function(i) {
  fr <- nhl_goal_tracking(goals$game_id[i], goals$event_id[i])
  cbind(goals[i, c("event_id", "event_team", "player_1_name")],
        classify_goal(fr, team = goals$event_team[i], shot_type = goals$shot_type[i])[, c("distance", "shot_speed", "kinds")])
}))
kinds
#>   event_id event_team       player_1_name distance shot_speed            kinds
#> 1      296        EDM Ryan Nugent-Hopkins      5.4       19.2            cross
#> 2      393        BOS         Pavel Zacha      8.1       34.0             rush
#> 3      685        EDM        Quinn Hutson      7.2       30.3 cross, forecheck
#> 4      777        EDM      Connor McDavid      7.5       24.1  rush, breakaway
```

See
[`vignette("goal-tracking")`](https://ethanrawson.github.io/bluelineR/articles/goal-tracking.md)
for one goal in detail.

## NHL EDGE

``` r

nhl_edge_leaders("skater_shot_speed", season = "2025-26")[, c("rank", "player_first_name", "player_last_name", "player_team_abbrev", "hardest_shot_imperial")]
#> # A tibble: 10 × 5
#>     rank player_first_name player_last_name player_team_abbrev hardest_shot_imperial
#>    <int> <chr>             <chr>            <chr>                              <dbl>
#>  1     1 Tyler             Kleven           OTT                                 104.
#>  2     2 Morgan            Geekie           BOS                                 103.
#>  3     3 Ryan              Pulock           NYI                                 103.
#>  4     4 Louis             Crevier          CHI                                 103.
#>  5     5 J.T.              Miller           NYR                                 103.
#>  6     6 Colin             Miller           WPG                                 102.
#>  7     7 Jake              Walman           EDM                                 102.
#>  8     8 Brandon           Montour          SEA                                 102.
#>  9     9 Victor            Hedman           TBL                                 101.
#> 10    10 Conor             Timmins          BUF                                 101.

nhl_edge_team("EDM", "2025-26", report = "zone_time")$zone_time_details
#> # A tibble: 4 × 10
#>   strength_code offensive_zone_pctg offensive_zone_rank offensive_zone_league_avg
#>   <chr>                       <dbl>               <int>                     <dbl>
#> 1 all                         0.418                   7                     0.415
#> 2 es                          0.415                   8                     0.410
#> 3 pp                          0.592                  18                     0.580
#> 4 pk                          0.279                   8                     0.298
#> # ℹ 6 more variables: neutral_zone_pctg <dbl>, neutral_zone_rank <int>,
#> #   neutral_zone_league_avg <dbl>, defensive_zone_pctg <dbl>, defensive_zone_rank <int>,
#> #   defensive_zone_league_avg <dbl>
```

## Players and clubs

``` r

nhl_player_search("hughes", active = TRUE)[, c("player_id", "name", "team_abbrev", "position_code")]
#> # A tibble: 5 × 4
#>   player_id name           team_abbrev position_code
#>       <dbl> <chr>          <chr>       <chr>        
#> 1   8481559 Jack Hughes    NJD         C            
#> 2   8486171 T.J. Hughes    COL         R            
#> 3   8478888 Cameron Hughes DAL         C            
#> 4   8482684 Luke Hughes    NJD         D            
#> 5   8480800 Quinn Hughes   MIN         D

log <- nhl_player_game_log(8478402, "2025-26")
sum(log$goals)
#> [1] 48

nhl_roster("EDM")[, c("full_name", "sweater_number", "position_code", "birth_country")]
#> # A tibble: 28 × 4
#>   full_name       sweater_number position_code birth_country
#>   <chr>                    <int> <chr>         <chr>        
#> 1 Colton Dach                 34 C             CAN          
#> 2 Jason Dickinson             16 C             CAN          
#> 3 Leon Draisaitl              29 C             DEU          
#> 4 Alex Formenton              26 L             CAN          
#> 5 Trent Frederic              10 C             USA          
#> # ℹ 23 more rows
```

## The stats and records APIs

[`nhl_stats()`](https://ethanrawson.github.io/bluelineR/reference/nhl_stats.md)
reaches every report behind NHL.com/stats, with the API’s own filters:

``` r

nhl_stats("goalie/summary", "2025-26", filter = "gamesPlayed>=30", sort = "+goalsAgainstAverage", limit = 5)[, c("goalie_full_name", "games_played", "goals_against_average", "save_pct")]
#> # A tibble: 5 × 4
#>   goalie_full_name   games_played goals_against_average save_pct
#>   <chr>                     <int>                 <dbl>    <dbl>
#> 1 Scott Wedgewood              45                  2.02    0.921
#> 2 Andrei Vasilevskiy           58                  2.31    0.912
#> 3 Dan Vladar                   52                  2.42    0.906
#> 4 Casey DeSmith                30                  2.43    0.907
#> 5 Logan Thompson               58                  2.44    0.912

nhl_records("draft", filter = "draftYear=2015 and roundNumber=1")[1:5, c("overall_pick_number", "player_name", "tri_code", "amateur_club_name")]
#> # A tibble: 5 × 4
#>   overall_pick_number player_name    tri_code amateur_club_name
#>                 <int> <chr>          <chr>    <chr>            
#> 1                   1 Connor McDavid EDM      Erie             
#> 2                   2 Jack Eichel    BUF      Boston University
#> 3                   3 Dylan Strome   ARI      Erie             
#> 4                   4 Mitch Marner   TOR      London           
#> 5                   5 Noah Hanifin   CAR      Boston College
```

## Anything else

[`nhl_api()`](https://ethanrawson.github.io/bluelineR/reference/nhl_api.md)
calls any endpoint and
[`tidy_json()`](https://ethanrawson.github.io/bluelineR/reference/tidy_json.md)
tidies what comes back:

``` r

nhl_api("network/tv-schedule/now", tidy = TRUE)$broadcasts
#> # A tibble: 31 × 9
#>   start_time       end_time duration_seconds title description house_number broadcast_type
#>   <chr>            <chr>               <int> <chr> <chr>       <chr>        <chr>         
#> 1 2026-10-22T00:0… 2026-10…             1800 On T… On The Fly  HOTF27R1021… HD            
#> 2 2026-10-22T00:3… 2026-10…             1800 On T… On The Fly  HOTF27R1021… HD            
#> 3 2026-10-22T01:0… 2026-10…             1800 On T… On The Fly  HOTF27R1021… HD            
#> 4 2026-10-22T01:3… 2026-10…             1800 On T… On The Fly  HOTF27R1021… HD            
#> 5 2026-10-22T02:0… 2026-10…             1800 On T… On The Fly  HOTF27R1021… HD            
#> # ℹ 26 more rows
#> # ℹ 2 more variables: broadcast_status <chr>, broadcast_image_url <chr>
```
