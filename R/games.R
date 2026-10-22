#' Scores and the schedule
#'
#' `nhl_scores()` is every game on a date with its score and state (the NHL's
#' scoreboard). `nhl_schedule()` is the week of games starting on a date.
#' `nhl_team_schedule()` is one club's whole season.
#'
#' @param date A date (or `"YYYY-MM-DD"`); `NULL` or `"now"` for today.
#' @return A tibble, one row per game.
#' @export
#' @examplesIf interactive()
#' nhl_scores("2026-10-20")
#' nhl_schedule()
#' nhl_team_schedule("EDM", "2025-26")
nhl_scores <- function(date = NULL) {
  raw <- fetch_json(api_url("web", "score", as_date_string(date)))
  games <- records_to_tibble(raw$games)
  if (!nrow(games)) return(games)
  games$game_date <- as.Date(games$game_date)
  front(games, c("id", "season", "game_type", "game_date", "start_time_utc", "game_state",
                 "away_team_abbrev", "away_team_score", "away_team_sog",
                 "home_team_abbrev", "home_team_score", "home_team_sog",
                 "period", "game_outcome_last_period_type"))
}

#' @rdname nhl_scores
#' @export
nhl_schedule <- function(date = NULL) {
  raw <- fetch_json(api_url("web", "schedule", as_date_string(date)))
  days <- lapply(raw$gameWeek, function(d) {
    g <- records_to_tibble(d$games)
    if (nrow(g)) g$date <- as.Date(d$date)
    g
  })
  days <- Filter(nrow, days)
  if (!length(days)) return(tibble::tibble())
  front(bind_rows_fill(days), c("date", "id", "season", "game_type", "start_time_utc", "game_state",
                                "away_team_abbrev", "home_team_abbrev"))
}

#' @rdname nhl_scores
#' @param team Club abbreviation (`"EDM"`) or team id.
#' @param season Season (see [nhl_season()]); `NULL` for the current one.
#' @export
nhl_team_schedule <- function(team, season = NULL) {
  raw <- fetch_json(api_url("web", "club-schedule-season", team_lookup(team), nhl_season(season)))
  games <- records_to_tibble(raw$games)
  if (nrow(games)) games$game_date <- as.Date(games$game_date)
  front(games, c("id", "season", "game_type", "game_date", "start_time_utc", "game_state",
                 "away_team_abbrev", "away_team_score", "home_team_abbrev", "home_team_score"))
}

#' Standings
#'
#' The league table on a date: points, record, goal differential, streaks,
#' home and road splits and the last ten games, one row per club.
#'
#' @inheritParams nhl_scores
#' @return A tibble, one row per club.
#' @export
#' @examplesIf interactive()
#' nhl_standings()
#' nhl_standings("2026-04-15")
nhl_standings <- function(date = NULL) {
  raw <- fetch_json(api_url("web", "standings", as_date_string(date)))
  st <- records_to_tibble(raw$standings)
  front(st, c("team_abbrev", "team_name", "conference_name", "division_name", "games_played",
              "wins", "losses", "ot_losses", "points", "point_pctg", "goal_for", "goal_against",
              "goal_differential", "streak_code", "streak_count"))
}

#' Play-by-play
#'
#' Every event in a game, one row each, with the clock as seconds, the
#' strength (`situation_code` read as skaters a side), the players involved
#' by id and name, the running score, and the location twice: as the feed has
#' it (`x`, `y`, feet from centre ice) and turned so the event's team always
#' attacks to the right (`x_fixed`, `y_fixed`), the usual frame for shot maps.
#'
#' @param game_id Ten-digit NHL game id, e.g. `2025020534`.
#' @return A tibble, one row per event.
#' @export
#' @examplesIf interactive()
#' pbp <- nhl_pbp(2025020534)
#' pbp[pbp$type == "goal", c("period", "time_in_period", "event_team", "player_1_name")]
nhl_pbp <- function(game_id) {
  parse_pbp(fetch_json(api_url("web", "gamecenter", check_game_id(game_id), "play-by-play")))
}

parse_pbp <- function(raw) {
  plays <- records_to_tibble(raw$plays)
  if (!nrow(plays)) return(plays)
  names(plays) <- sub("^details_", "", names(plays))
  names(plays)[names(plays) == "period_descriptor_number"] <- "period"
  names(plays)[names(plays) == "period_descriptor_period_type"] <- "period_type"
  names(plays)[names(plays) == "type_desc_key"] <- "type"
  plays$period_descriptor_max_regulation_periods <- NULL

  teams <- stats::setNames(c(raw$awayTeam$abbrev, raw$homeTeam$abbrev), c(raw$awayTeam$id, raw$homeTeam$id))
  spots <- raw$rosterSpots
  who <- stats::setNames(
    vapply(spots, function(s) paste(s$firstName$default %||% "", s$lastName$default %||% ""), character(1)),
    vapply(spots, function(s) as.character(s$playerId), character(1))
  )
  name_of <- function(id) unname(who[as.character(id)])
  col <- function(nm) if (nm %in% names(plays)) plays[[nm]] else rep(NA, nrow(plays))
  first_of <- function(...) {
    out <- rep(NA_real_, nrow(plays))
    for (nm in c(...)) out <- ifelse(is.na(out), as.numeric(col(nm)), out)
    out
  }

  plays$game_id <- raw$id
  plays$event_team <- unname(teams[as.character(col("event_owner_team_id"))])
  home <- raw$homeTeam$abbrev
  plays$event_team_type <- ifelse(is.na(plays$event_team), NA, ifelse(plays$event_team == home, "home", "away"))
  plays$period_seconds <- clock_seconds(plays$time_in_period)
  plays$game_seconds <- (plays$period - 1) * 1200 + plays$period_seconds

  sit <- as.character(col("situation_code"))
  digit <- function(i) suppressWarnings(as.integer(substr(sit, i, i)))
  plays$away_goalie <- digit(1) == 1
  plays$away_skaters <- digit(2)
  plays$home_skaters <- digit(3)
  plays$home_goalie <- digit(4) == 1
  mine <- ifelse(plays$event_team_type == "home", plays$home_skaters, plays$away_skaters)
  theirs <- ifelse(plays$event_team_type == "home", plays$away_skaters, plays$home_skaters)
  plays$strength_state <- ifelse(is.na(mine), NA, paste0(mine, "v", theirs))
  plays$empty_net <- ifelse(plays$event_team_type == "home", !plays$away_goalie,
                            ifelse(plays$event_team_type == "away", !plays$home_goalie, NA))

  plays$player_1_id <- first_of("scoring_player_id", "shooting_player_id", "winning_player_id",
                                "hitting_player_id", "committed_by_player_id", "player_id")
  plays$player_2_id <- first_of("assist1_player_id", "blocking_player_id", "losing_player_id",
                                "hittee_player_id", "drawn_by_player_id")
  plays$player_3_id <- first_of("assist2_player_id")
  plays$goalie_id <- first_of("goalie_in_net_id")
  for (k in c("player_1", "player_2", "player_3", "goalie")) {
    plays[[paste0(k, "_name")]] <- name_of(plays[[paste0(k, "_id")]])
  }

  # Running score: the feed carries it on goals only.
  fill <- function(v) { last <- 0; for (i in seq_along(v)) if (is.na(v[[i]])) v[[i]] <- last else last <- v[[i]]; v }
  plays$away_score <- fill(as.numeric(col("away_score")))
  plays$home_score <- fill(as.numeric(col("home_score")))

  plays$x <- as.numeric(col("x_coord"))
  plays$y <- as.numeric(col("y_coord"))
  # The home side defends `home_team_defending_side`; the event's team
  # attacks the other end. Turned so it always attacks to the right.
  side <- as.character(col("home_team_defending_side"))
  attacks_right <- ifelse(plays$event_team_type == "home", side == "left", side == "right")
  flip <- ifelse(is.na(attacks_right), NA, ifelse(attacks_right, 1, -1))
  plays$x_fixed <- plays$x * flip
  plays$y_fixed <- plays$y * flip
  plays$x_coord <- NULL
  plays$y_coord <- NULL

  front(plays, c("game_id", "event_id", "sort_order", "period", "period_type", "time_in_period",
                 "time_remaining", "period_seconds", "game_seconds", "type", "event_team", "event_team_type",
                 "x", "y", "x_fixed", "y_fixed", "zone_code", "shot_type", "strength_state", "situation_code",
                 "home_skaters", "away_skaters", "empty_net", "player_1_id", "player_1_name",
                 "player_2_id", "player_2_name", "player_3_id", "player_3_name", "goalie_id", "goalie_name",
                 "away_score", "home_score"))
}

#' Box score
#'
#' Player lines for both clubs: skaters (goals, assists, shots, hits, ice
#' time and more) and goalies (shots and saves by strength), plus the teams.
#'
#' @inheritParams nhl_pbp
#' @return A list of tibbles: `skaters`, `goalies` and `teams`.
#' @export
#' @examplesIf interactive()
#' nhl_boxscore(2025020534)$skaters
nhl_boxscore <- function(game_id) {
  parse_boxscore(fetch_json(api_url("web", "gamecenter", check_game_id(game_id), "boxscore")))
}

parse_boxscore <- function(raw) {
  side <- function(key, group) {
    team <- raw[[key]]$abbrev
    rows <- records_to_tibble(raw$playerByGameStats[[key]][[group]])
    if (!nrow(rows)) return(rows)
    rows$team <- team
    rows$team_type <- sub("Team$", "", key)
    rows$position_group <- group
    rows
  }
  skaters <- bind_rows_fill(list(side("awayTeam", "forwards"), side("awayTeam", "defense"),
                                 side("homeTeam", "forwards"), side("homeTeam", "defense")))
  goalies <- bind_rows_fill(list(side("awayTeam", "goalies"), side("homeTeam", "goalies")))
  skaters$toi_seconds <- clock_seconds(skaters$toi)
  goalies$toi_seconds <- clock_seconds(goalies$toi)
  teams <- records_to_tibble(list(raw$awayTeam, raw$homeTeam))
  teams$team_type <- c("away", "home")
  list(
    skaters = front(skaters, c("team", "team_type", "player_id", "name", "sweater_number", "position")),
    goalies = front(goalies, c("team", "team_type", "player_id", "name", "sweater_number")),
    teams = front(teams, c("team_type", "abbrev", "score", "sog"))
  )
}

#' Game summary
#'
#' The gamecenter landing page's data, tidied: the scoring summary, three
#' stars, penalties and the clubs, as tibbles (see [tidy_json()]).
#'
#' @inheritParams nhl_pbp
#' @return A named list of tibbles.
#' @export
#' @examplesIf interactive()
#' game <- nhl_game(2025020534)
#' game$info
nhl_game <- function(game_id) {
  tidy_json(fetch_json(api_url("web", "gamecenter", check_game_id(game_id), "landing")))
}

#' Shift charts
#'
#' Every shift each player took: when it started and ended (as the period
#' clock and as seconds into the game) and how long it lasted.
#'
#' @inheritParams nhl_pbp
#' @param shifts_only Drop the goal rows the NHL mixes into the chart.
#' @return A tibble, one row per shift.
#' @export
#' @examplesIf interactive()
#' shifts <- nhl_shifts(2025020534)
#' aggregate(duration_seconds ~ player_name, shifts, sum)
nhl_shifts <- function(game_id, shifts_only = TRUE) {
  raw <- fetch_json(api_url("stats", "shiftcharts"), query = list(cayenneExp = paste0("gameId=", check_game_id(game_id))))
  parse_shifts(raw, shifts_only)
}

parse_shifts <- function(raw, shifts_only = TRUE) {
  sh <- records_to_tibble(raw$data)
  if (!nrow(sh)) return(sh)
  if (shifts_only) sh <- sh[sh$type_code == 517, , drop = FALSE]
  sh$player_name <- paste(sh$first_name, sh$last_name)
  sh$start_seconds <- clock_seconds(sh$start_time)
  sh$end_seconds <- clock_seconds(sh$end_time)
  sh$duration_seconds <- clock_seconds(sh$duration)
  sh$game_start_seconds <- (sh$period - 1) * 1200 + sh$start_seconds
  sh$game_end_seconds <- (sh$period - 1) * 1200 + sh$end_seconds
  sh <- sh[order(sh$team_abbrev, sh$player_id, sh$period, sh$start_seconds), , drop = FALSE]
  front(sh, c("game_id", "team_abbrev", "player_id", "player_name", "period", "shift_number",
              "start_time", "end_time", "duration", "start_seconds", "end_seconds", "duration_seconds",
              "game_start_seconds", "game_end_seconds"))
}

# rbind for tibbles whose columns differ: missing columns become NA.
bind_rows_fill <- function(dfs) {
  dfs <- Filter(function(d) !is.null(d) && nrow(d) > 0, dfs)
  if (!length(dfs)) return(tibble::tibble())
  tibble::as_tibble(vctrs::vec_rbind(!!!dfs))
}
