#' Coaches and general managers
#'
#' Every NHL head coach and general manager, from records.nhl.com:
#'
#' * `by = "career"`: each one's whole NHL career: seasons, clubs, games, wins,
#'   losses, ties and overtime losses, win percentage, Stanley Cups and Cup
#'   Final appearances, and the Jack Adams (coaches) or GM of the Year awards.
#' * `by = "team"`: the same, with each club he coached or ran, with the dates
#'   (a GM's are the day he was hired and the day he left).
#' * `by = "bio"`: where and when he was born, his nationality, the Hockey
#'   Hall of Fame, and his NHL player id if he played (`player_id`, for
#'   [nhl_player()]); for GMs the record's own notes on each hiring and firing.
#'
#' @param by `"career"`, `"team"` or `"bio"`.
#' @param game_type `"regular"` or `"playoffs"` (not used for `"bio"`).
#' @param active `TRUE` for those in the job now (by `"team"`, just the club
#'   each has now), `FALSE` for the rest, `NULL` for everyone.
#' @return A tibble, the winningest first (bios by name).
#' @export
#' @examplesIf interactive()
#' nhl_coaches()
#' nhl_coaches("team", active = TRUE)
#' nhl_coaches("career", "playoffs")[, c("name", "games", "wins", "stanley_cups")]
#' nhl_general_managers("team", active = TRUE)
#' nhl_general_managers("bio")
nhl_coaches <- function(by = c("career", "team", "bio"), game_type = "regular", active = NULL) {
  by <- match.arg(by)
  resource <- switch(by, career = "coach-career-records", team = "coach-franchise-records", bio = "coach")
  out <- staff_table(resource, by, game_type)
  out <- rename_cols(out, c(coach_name = "name", full_name = "name", active_coach = "active", is_active = "active",
                            team_abbrev = "team", team_abbrevs = "teams", start_season = "first_season",
                            end_season = "last_season", birth_country3code = "birth_country"))
  staff_finish(out, by, active)
}

#' @rdname nhl_coaches
#' @export
nhl_general_managers <- function(by = c("career", "team", "bio"), game_type = "regular", active = NULL) {
  by <- match.arg(by)
  resource <- switch(by, career = "general-manager-career-records", team = "general-manager-franchise-records",
                     bio = "general-manager")
  out <- staff_table(resource, by, game_type)
  out <- rename_cols(out, c(full_name = "name", active_gm = "active", team_name = "franchise", team_abbrevs = "teams",
                            start_season_id = "first_season", end_season_id = "last_season",
                            overtime_losses = "ot_losses", birth_country_code = "birth_country"))
  if (by == "team" && nrow(out)) out$team <- nhl_team_code(out$team_id)
  staff_finish(out, by, active)
}

staff_table <- function(resource, by, game_type) {
  filter <- if (by != "bio") sprintf("gameTypeId=%d", nhl_game_type(game_type))
  nhl_records(resource, filter = filter)
}

staff_finish <- function(out, by, active) {
  if (!nrow(out)) return(out)
  if ("active" %in% names(out)) out$active <- as.logical(out$active)
  if (!is.null(active)) out <- out[out$active %in% active, ]
  # Active means in a job now; by club, keep only the club he has now.
  if (by == "team" && isTRUE(active) && nrow(out)) out <- out[out$last_season %in% max(out$last_season, na.rm = TRUE), ]
  for (d in intersect(c("start_date", "end_date", "first_coached_date", "last_coached_date", "birth_date"), names(out))) {
    out[[d]] <- as.Date(substr(out[[d]], 1, 10))
  }
  drop <- c("id", "first_name", "last_name", "game_type_id", "bio", "description", "brief_description", "featured_image",
            "history", "instagram", "twitter", "top100_player_link", "hockey_hof_link")
  out <- out[, setdiff(names(out), drop), drop = FALSE]
  if (by == "bio") return(front(out[order(out$name), ], c("name", "active", "birth_date", "birth_city", "nationality_code")))
  out <- out[order(-out$wins, -out$games), ]
  front(out, c("name", "active", "team", "franchise", "teams", "first_season", "last_season", "seasons", "games", "wins",
               "losses", "ties", "ot_losses", "win_pctg", "point_pctg", "stanley_cups", "stanley_cup_final_appearances"))
}

# Club code from the NHL's team id (records' GM tables give the id only).
nhl_team_code <- function(team_id) {
  info <- nhl_team_info()
  info$abbrev[match(team_id, info$team_id)]
}
