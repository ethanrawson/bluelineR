#' Game tracking summaries
#'
#' The NHL's tracking vendor writes three files per game alongside the
#' play-by-play, at `live.nhle.com/ppt/{season}/{game}`. NHL.com's tracking
#' module reads them; they are not among the NHL EDGE endpoints.
#'
#' * `nhl_tracking_summary()`: each player's game from the tracking: time on
#'   the ice, top and average skating speed, distance, time and shift starts
#'   in each zone, and **puck possession time** (in all, by zone and by
#'   strength), with each club's possession time and share by zone and
#'   strength, and the puck's own top speed.
#' * `nhl_tracking_player_stats()`: the vendor's box score: ice time by
#'   strength (5v5, 5v4, 4v5...), shifts and their lengths, faceoffs by zone
#'   and strength, shots by strength, and each shift as a list-column.
#' * `nhl_tracking_entities()`: who the tracking follows: players (with
#'   their NHL id, height, weight, handedness), officials and the puck.
#'
#' Speeds are in miles per hour (`speed_max_mph`, `speed_avg_mph`; the files
#' keep feet per second), distances in miles and feet, times in seconds.
#'
#' **Coverage**: the summaries and player stats exist for most regular-season
#' games from 2021-22 to 2023-24, some of 2020-21 and 2024-25, and none from
#' 2025-26 on, when only the entity list is still written. Playoff games are
#' mostly missing.
#'
#' @param game_id Ten-digit NHL game id.
#' @return `nhl_tracking_summary()`: a list of tibbles, `players`, `teams`,
#'   `puck` and `info`. The others: a tibble.
#' @export
#' @examplesIf interactive()
#' tr <- nhl_tracking_summary(2023020500)
#' tr$teams[, c("team", "possession_pct", "possession_pct_o_zone")]
#' top <- tr$players[order(-tr$players$possession_time), ]
#' top[, c("name", "team", "possession_time", "speed_max_mph", "distance_miles")]
nhl_tracking_summary <- function(game_id) {
  game_id <- check_game_id(game_id)
  entities <- nhl_tracking_entities(game_id)
  raw <- ppt_file(game_id, "LiveEventSummary.json")[[1]]
  s <- records_to_tibble(raw$EntitySummaries)
  s$entity_id <- as.character(s$entity_id)
  s <- merge(s, entities[, c("entity_id", "entity_type", "player_id", "name", "team", "position", "jersey_num")],
             by = "entity_id", all.x = TRUE, sort = FALSE)
  s <- tibble::as_tibble(s)
  for (k in c("speed_max", "speed_avg", "speed")) if (k %in% names(s)) s[[paste0(k, "_mph")]] <- s[[k]] / 1.467
  if ("distance_total" %in% names(s)) {
    s$distance_ft <- s$distance_total
    s$distance_miles <- s$distance_total / 5280
  }
  players <- s[s$entity_type %in% "Player", , drop = FALSE]
  players <- players[order(players$team, -players$time_on_total), , drop = FALSE]
  players <- front(players, c("player_id", "name", "team", "position", "jersey_num", "time_on_total",
                              "speed_max_mph", "speed_avg_mph", "distance_miles", "zone_offense_time",
                              "zone_neutral_time", "zone_defense_time", "zone_offense_starts", "zone_neutral_starts",
                              "zone_defense_starts", "possession_time", "possession_time_o_zone",
                              "possession_time_n_zone", "possession_time_d_zone"))
  puck <- front(s[s$entity_type %in% "BallOrPuck", , drop = FALSE], c("entity_id", "speed_max_mph", "distance_miles"))

  teams <- records_to_tibble(raw$TeamSummaries)
  codes <- unique(entities[!is.na(entities$team_id), c("team_id", "team")])
  teams$team <- codes$team[match(as.character(teams$team_id), as.character(codes$team_id))]
  teams <- front(teams, c("team", "team_id", "possession_time", "possession_pct"))

  info <- tibble::tibble(game_id = as.numeric(game_id), home_direction_of_play = raw$HomeDirectionOfPlay %||% NA,
                         period = raw$EventTime$Period %||% NA, as_of_utc = raw$NowUTC %||% NA)
  list(players = players, teams = teams, puck = puck, info = info)
}

#' @rdname nhl_tracking_summary
#' @export
nhl_tracking_player_stats <- function(game_id) {
  game_id <- check_game_id(game_id)
  raw <- ppt_file(game_id, "PlayerStats.json")
  shifts <- lapply(raw, function(r) records_to_tibble(r$ShiftsAll %||% list()))
  raw <- lapply(raw, function(r) { r$ShiftsAll <- NULL; r })
  out <- records_to_tibble(raw)
  out$player_id <- as.numeric(out$official_id)
  out$official_id <- NULL
  out$shift_list <- shifts
  entities <- nhl_tracking_entities(game_id)
  out$name <- entities$name[match(out$player_id, entities$player_id)]
  out$team <- entities$team[match(out$player_id, entities$player_id)]
  front(out, c("player_id", "name", "team", "toi_total", "toi_5v5", "toi_power_play", "toi_short_handed", "shifts"))
}

#' @rdname nhl_tracking_summary
#' @export
nhl_tracking_entities <- function(game_id) {
  game_id <- check_game_id(game_id)
  raw <- ppt_file(game_id, "EntityRegistration.json")[[1]]
  ent <- records_to_tibble(raw$Entities)
  teams <- records_to_tibble(raw$Teams)
  ent$entity_id <- as.character(ent$entity_id)
  ent$player_id <- suppressWarnings(as.numeric(ifelse(ent$entity_type == "Player", ent$official_id, NA)))
  ent$name <- trimws(paste(ent$first_name, ent$last_name))
  ent$team_id <- ent$entity_team_id
  ent$team <- teams$code[match(ent$entity_team_id, teams$official_id)]
  ent$team[ent$entity_type != "Player"] <- NA
  front(ent, c("entity_id", "entity_type", "player_id", "name", "team", "team_id", "position", "jersey_num",
               "height", "weight", "handed", "dob"))
}

ppt_file <- function(game_id, file) {
  url <- api_url("ppt", season_of_game(game_id), game_id, file)
  tryCatch(fetch_json(url), bluelineR_http_error = function(e) no_ppt(e), bluelineR_not_found = function(e) no_ppt(e))
}

no_ppt <- function(e) {
  cli::cli_abort(c("The NHL has no tracking summary for this game.",
                   i = "They exist for most regular-season games from 2021-22 to 2023-24 and some of 2020-21 and 2024-25; from 2025-26 only the entity list is written."),
                 parent = e, class = "bluelineR_no_tracking")
}
