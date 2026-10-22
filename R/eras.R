#' What the NHL kept, and since when
#'
#' The NHL's numbers do not all go back to 1917-18. Goals, assists and
#' penalty minutes do, for every season and every game; shots, plus/minus,
#' ice time, hits and shot locations each start later, and a column the
#' league did not keep comes back missing for the seasons before it. These
#' tables say where each one starts, measured against the live API.
#'
#' `nhl_stat_eras()` gives the eras: what each adds and the bluelineR
#' functions that reach it. With `by = "stat"` it gives the first season of
#' every column of the stats reports ([nhl_stats()]); `stat` keeps the ones
#' named.
#'
#' @param by `"era"` or `"stat"`.
#' @param stat With `by = "stat"`, column names to keep (as bluelineR returns
#'   them, e.g. `"shots"`, `"hits"`, `"time_on_ice_per_game"`).
#' @return A tibble. Seasons are written like `"1959-60"`.
#' @export
#' @examples
#' nhl_stat_eras()
#' nhl_stat_eras("stat", c("shots", "plus_minus", "hits"))
nhl_stat_eras <- function(by = c("era", "stat"), stat = NULL) {
  by <- match.arg(by)
  if (by == "era") return(stat_eras)
  out <- stat_since
  if (!is.null(stat)) out <- out[out$stat %in% stat, ]
  out
}

# Measured against the live API in October 2026: for each season, the share
# of the top skaters, goalies and teams with a value (or, for counts the
# league fills with zeros before it kept them, a non-zero value).
stat_eras <- tibble::tribble(
  ~from, ~to, ~adds, ~functions,
  "1917-18", NA, "Games, goals, assists, points, penalty minutes and game-winning goals; goalies' wins, losses, goals against, shutouts and ice time; team records. Every game's boxscore, player game logs, and play-by-play of goals and penalties",
    "nhl_stats(), nhl_player(), nhl_player_game_log(), nhl_boxscore(), nhl_pbp(), nhl_records()",
  "1933-34", NA, "Even-strength, power-play and short-handed goals and points", "nhl_stats()",
  "1955-56", NA, "Goalies' shots against, saves, save percentage and quality starts", "nhl_stats(\"goalie/summary\"), nhl_stats(\"goalie/advanced\")",
  "1959-60", NA, "Skaters' shots and plus/minus (shooting percentage from 1960-61); teams' shots for and against", "nhl_stats()",
  "1977-78", NA, "Team power-play and penalty-kill percentages, with opportunities and times shorthanded", "nhl_stats(\"team/powerplay\"), nhl_stats(\"team/penaltykill\")",
  "1997-98", NA, "Ice time and shifts, at even strength, on the power play and shorthanded; faceoffs; goalies' saves by strength. Play-by-play adds shots on goal, without locations",
    "nhl_stats(\"skater/timeonice\"), nhl_stats(\"skater/faceoffwins\"), nhl_stats(\"goalie/savesByStrength\"), nhl_pbp()",
  "1999-00", NA, "Teams' overtime losses (goalies' from 2005-06)", "nhl_stats(\"team/summary\")",
  "2005-06", NA, "Hits, blocked shots, giveaways, takeaways and missed shots; shootouts", "nhl_stats(\"skater/realtime\"), nhl_stats(\"team/realtime\")",
  "2009-10", NA, "Every event in the play-by-play with its location (faceoffs, hits, blocks, misses, giveaways, takeaways, stoppages), so shot maps; shot attempts, zone faceoffs, 5-on-5 and overtime ice time, goalies' run support",
    "nhl_pbp(), plot_shots(), nhl_stats()",
  "2010-11", NA, "Shift charts", "nhl_shifts()",
  "2021-22", NA, "NHL EDGE puck and player tracking: skating speed and distance, shot speed, zone time and shot location", "nhl_edge_skater(), nhl_edge_goalie(), nhl_edge_team(), nhl_edge_leaders()",
  "2021-22", "2023-24", "Game tracking summaries (also some games of 2020-21 and 2024-25)", "nhl_tracking_summary(), nhl_tracking_player_stats()",
  "2022-23", NA, "Each skater's total shot attempts and attempts blocked", "nhl_stats(\"skater/realtime\")",
  "2023-24", NA, "Goal tracking: every player and the puck through each goal, ten frames a second", "nhl_goal_tracking(), plot_goal(), animate_goal()"
)

stat_since <- tibble::tribble(
  ~report, ~stat, ~first_season,
  "skater/summary", "games_played", "1917-18",
  "skater/summary", "goals", "1917-18",
  "skater/summary", "assists", "1917-18",
  "skater/summary", "points", "1917-18",
  "skater/summary", "points_per_game", "1917-18",
  "skater/summary", "penalty_minutes", "1917-18",
  "skater/summary", "game_winning_goals", "1917-18",
  "skater/summary", "ot_goals", "1917-18",
  "skater/summary", "ev_goals", "1933-34",
  "skater/summary", "ev_points", "1933-34",
  "skater/summary", "pp_goals", "1933-34",
  "skater/summary", "pp_points", "1933-34",
  "skater/summary", "sh_goals", "1933-34",
  "skater/summary", "sh_points", "1933-34",
  "skater/summary", "shots", "1959-60",
  "skater/summary", "plus_minus", "1959-60",
  "skater/summary", "shooting_pct", "1960-61",
  "skater/summary", "faceoff_win_pct", "1997-98",
  "skater/summary", "time_on_ice_per_game", "1997-98",
  "skater/realtime", "hits", "2005-06",
  "skater/realtime", "blocked_shots", "2005-06",
  "skater/realtime", "giveaways", "2005-06",
  "skater/realtime", "takeaways", "2005-06",
  "skater/realtime", "missed_shots", "2005-06",
  "skater/realtime", "missed_shot_goalpost", "2009-10",
  "skater/realtime", "missed_shot_over_net", "2009-10",
  "skater/realtime", "missed_shot_wide_of_net", "2009-10",
  "skater/realtime", "total_shot_attempts", "2022-23",
  "skater/realtime", "shot_attempts_blocked", "2022-23",
  "skater/realtime", "missed_shot_crossbar", "2023-24",
  "skater/realtime", "missed_shot_short", "2023-24",
  "skater/realtime", "missed_shot_failed_bank_attempt", "2024-25",
  "skater/timeonice", "time_on_ice", "1997-98",
  "skater/timeonice", "ev_time_on_ice", "1997-98",
  "skater/timeonice", "pp_time_on_ice", "1997-98",
  "skater/timeonice", "sh_time_on_ice", "1997-98",
  "skater/timeonice", "shifts", "1997-98",
  "skater/timeonice", "ot_time_on_ice", "2009-10",
  "skater/faceoffwins", "total_faceoffs", "1997-98",
  "skater/faceoffwins", "ev_faceoffs", "1997-98",
  "skater/faceoffwins", "pp_faceoffs", "1997-98",
  "skater/faceoffwins", "sh_faceoffs", "1997-98",
  "skater/faceoffwins", "offensive_zone_faceoffs", "2009-10",
  "skater/faceoffwins", "neutral_zone_faceoffs", "2009-10",
  "skater/faceoffwins", "defensive_zone_faceoffs", "2009-10",
  "skater/powerplay", "pp_assists", "1933-34",
  "skater/powerplay", "pp_shots", "1997-98",
  "skater/powerplay", "pp_time_on_ice", "1997-98",
  "skater/powerplay", "pp_individual_sat_for", "2009-10",
  "goalie/summary", "games_played", "1917-18",
  "goalie/summary", "wins", "1917-18",
  "goalie/summary", "losses", "1917-18",
  "goalie/summary", "goals_against", "1917-18",
  "goalie/summary", "goals_against_average", "1917-18",
  "goalie/summary", "shutouts", "1917-18",
  "goalie/summary", "time_on_ice", "1917-18",
  "goalie/summary", "shots_against", "1955-56",
  "goalie/summary", "saves", "1955-56",
  "goalie/summary", "save_pct", "1955-56",
  "goalie/summary", "ot_losses", "2005-06",
  "goalie/advanced", "quality_start", "1955-56",
  "goalie/advanced", "goals_for", "2009-10",
  "goalie/savesByStrength", "ev_shots_against", "1997-98",
  "goalie/savesByStrength", "ev_save_pct", "1997-98",
  "goalie/savesByStrength", "pp_shots_against", "1997-98",
  "goalie/savesByStrength", "sh_shots_against", "1997-98",
  "team/summary", "points", "1917-18",
  "team/summary", "wins", "1917-18",
  "team/summary", "goals_for", "1917-18",
  "team/summary", "goals_against", "1917-18",
  "team/summary", "shots_for_per_game", "1959-60",
  "team/summary", "shots_against_per_game", "1959-60",
  "team/summary", "power_play_pct", "1977-78",
  "team/summary", "penalty_kill_pct", "1977-78",
  "team/summary", "faceoff_win_pct", "1997-98",
  "team/summary", "ot_losses", "1999-00",
  "team/powerplay", "pp_opportunities", "1977-78",
  "team/powerplay", "pp_time_on_ice_per_game", "1997-98",
  "team/penaltykill", "times_shorthanded", "1977-78",
  "team/penaltykill", "pk_time_on_ice_per_game", "1997-98",
  "team/realtime", "shots", "1959-60",
  "team/realtime", "hits", "2005-06",
  "team/realtime", "blocked_shots", "2005-06",
  "team/realtime", "giveaways", "2005-06",
  "team/realtime", "takeaways", "2005-06",
  "team/realtime", "missed_shots", "2005-06",
  "team/realtime", "sat_pct", "2009-10",
  "team/realtime", "time_on_ice_per_game_5v5", "2009-10",
  "team/realtime", "total_shot_attempts", "2022-23"
)

# The first season (as 19591960) a stats-report column is kept; NULL when
# the column is not in the table.
stat_first_season <- function(report, stat) {
  i <- which(stat_since$report == report & stat_since$stat == stat)
  if (!length(i)) return(NULL)
  as.numeric(sub("^(\\d{4})-\\d{2}$", "\\1", stat_since$first_season[[i[1]]])) * 10001 + 1
}

# Sorting by a column the NHL did not keep for some of the seasons asked for
# ranks those seasons' players by nothing; say so.
stat_era_check <- function(report, stat, seasons) {
  first <- stat_first_season(report, stat)
  if (!is.null(first) && min(seasons) < first) {
    cli::cli_inform(c(i = "The NHL kept {.field {stat}} from {season_label(first)}; before that it is missing or zero. See {.fn nhl_stat_eras}."))
  }
  invisible()
}

season_label <- function(season) {
  y <- as.integer(substr(as.character(season), 1, 4))
  sprintf("%d-%02d", y, (y + 1) %% 100)
}

# A word, once a session, when a game is older than the data asked for.
era_note <- function(game_id, what) {
  season <- season_of_game(game_id)
  if (what == "pbp" && season < 20092010) {
    kept <- if (season >= 19971998) "goals, penalties and shots on goal" else "goals and penalties"
    cli::cli_inform(c(i = "Play-by-play before 2009-10 has {kept} only, without locations; see {.fn nhl_stat_eras}."),
                    .frequency = "once", .frequency_id = paste0("bluelineR_pbp_", season >= 19971998))
  }
  if (what == "shifts" && season < 20102011) {
    cli::cli_inform(c(i = "The NHL's shift charts start in 2010-11; see {.fn nhl_stat_eras}."),
                    .frequency = "once", .frequency_id = "bluelineR_shifts")
  }
  invisible()
}
