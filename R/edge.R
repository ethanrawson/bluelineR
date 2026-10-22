#' NHL EDGE: skaters, goalies and teams
#'
#' NHL EDGE is the league's puck and player tracking, summed up by season:
#' skating speed and bursts, distance skated, shot speed, shots by location,
#' time in each zone and, for goalies, save percentage by location and at
#' 5-on-5. Each value comes with the league average and a percentile.
#'
#' `report` picks the endpoint: `"detail"` is the overview the NHL's EDGE
#' pages open with; the others are the full tables behind each tab;
#' `"comparison"` is everything at once, as the NHL's player comparison tool
#' uses it.
#'
#' @param player_id NHL player id.
#' @param season Season (see [nhl_season()]); `NULL` for the current one.
#' @param game_type `"regular"` or `"playoffs"`.
#' @param report Which table; see Details.
#' @return A named list of tibbles (see [tidy_json()]).
#' @name nhl_edge
#' @examplesIf interactive()
#' mcdavid <- nhl_edge_skater(8478402, "2025-26")
#' mcdavid$info
#' nhl_edge_skater(8478402, report = "speed")$top_skating_speeds
#' nhl_edge_goalie(8479361, report = "shot_location")
#' nhl_edge_team("EDM", report = "zone_time")
NULL

edge_get <- function(path, season, game_type) {
  season <- if (identical(season, "now")) "now" else nhl_season(season)
  parts <- c(path, if (identical(season, "now")) "now" else c(season, nhl_game_type(game_type)))
  tidy_json(fetch_json(do.call(api_url, c(list("web", "edge"), as.list(parts)))))
}

SKATER_REPORTS <- c(detail = "skater-detail", speed = "skater-skating-speed-detail",
                    distance = "skater-skating-distance-detail", shot_speed = "skater-shot-speed-detail",
                    zone_time = "skater-zone-time", shot_location = "skater-shot-location-detail",
                    comparison = "skater-comparison")
GOALIE_REPORTS <- c(detail = "goalie-detail", `5v5` = "goalie-5v5-detail",
                    save_pct = "goalie-save-percentage-detail", shot_location = "goalie-shot-location-detail",
                    comparison = "goalie-comparison")
TEAM_REPORTS <- c(detail = "team-detail", speed = "team-skating-speed-detail",
                  distance = "team-skating-distance-detail", shot_speed = "team-shot-speed-detail",
                  zone_time = "team-zone-time-details", shot_location = "team-shot-location-detail",
                  comparison = "team-comparison")

#' @rdname nhl_edge
#' @export
nhl_edge_skater <- function(player_id, season = NULL, game_type = "regular",
                            report = c("detail", "speed", "distance", "shot_speed", "zone_time", "shot_location", "comparison")) {
  report <- match.arg(report)
  edge_get(c(SKATER_REPORTS[[report]], player_id), season, game_type)
}

#' @rdname nhl_edge
#' @export
nhl_edge_goalie <- function(player_id, season = NULL, game_type = "regular",
                            report = c("detail", "5v5", "save_pct", "shot_location", "comparison")) {
  report <- match.arg(report)
  edge_get(c(GOALIE_REPORTS[[report]], player_id), season, game_type)
}

#' @rdname nhl_edge
#' @param team Club abbreviation (`"EDM"`) or team id.
#' @export
nhl_edge_team <- function(team, season = NULL, game_type = "regular",
                          report = c("detail", "speed", "distance", "shot_speed", "zone_time", "shot_location", "comparison")) {
  report <- match.arg(report)
  edge_get(c(TEAM_REPORTS[[report]], team_lookup(team, "team_id")), season, game_type)
}

#' NHL EDGE leaderboards
#'
#' The NHL's EDGE top 10s: fastest skaters, most distance skated, hardest
#' shots, most offensive-zone time, and the clubs' skating speed. `landing`
#' gives the leaders the EDGE home pages show for skaters, goalies or teams.
#'
#' @param metric Which leaderboard.
#' @param position `"all"`, `"F"` (forwards) or `"D"` (defence).
#' @param strength For distance and zone time: `"all"`, `"es"` (even
#'   strength), `"pp"` or `"pk"`.
#' @param sort_by The ranking: for speed and shot speed `"max"` (top speed)
#'   or a burst band (`"over22"`, `"20-22"`, `"18-20"` for skating speed;
#'   `"over100"`, `"90-100"`, `"80-90"`, `"70-80"` for shot speed); for
#'   distance `"total"` or `"max-game"`; for zone time `"offensive"`,
#'   `"neutral"` or `"defensive"`. `NULL` picks the first.
#' @inheritParams nhl_edge
#' @return A tibble, one row per player or club.
#' @export
#' @examplesIf interactive()
#' nhl_edge_leaders("skater_speed")
#' nhl_edge_leaders("skater_shot_speed", position = "D")
#' nhl_edge_landing("goalie")
nhl_edge_leaders <- function(metric = c("skater_speed", "skater_distance", "skater_shot_speed", "skater_zone_time", "team_skating_speed"),
                             position = c("all", "F", "D"), strength = c("all", "es", "pp", "pk"),
                             sort_by = NULL, season = NULL, game_type = "regular") {
  metric <- match.arg(metric)
  position <- match.arg(position)
  strength <- match.arg(strength)
  default_sort <- c(skater_speed = "max", skater_distance = "total", skater_shot_speed = "max",
                    skater_zone_time = "offensive", team_skating_speed = "max")
  sort_by <- sort_by %||% default_sort[[metric]]
  path <- switch(metric,
    skater_speed = c("skater-speed-top-10", position, sort_by),
    skater_distance = c("skater-distance-top-10", position, strength, sort_by),
    skater_shot_speed = c("skater-shot-speed-top-10", position, sort_by),
    skater_zone_time = c("skater-zone-time-top-10", position, strength, sort_by),
    team_skating_speed = c("team-skating-speed-top-10", position, sort_by)
  )
  out <- edge_get(path, season, game_type)
  if (tibble::is_tibble(out)) out$rank <- seq_len(nrow(out))
  front(out, "rank")
}

#' @rdname nhl_edge_leaders
#' @param type `"skater"`, `"goalie"` or `"team"`.
#' @export
nhl_edge_landing <- function(type = c("skater", "goalie", "team"), season = NULL, game_type = "regular") {
  type <- match.arg(type)
  edge_get(paste0(type, "-landing"), season, game_type)
}

#' Last night by the numbers
#'
#' The NHL EDGE standouts from the most recent night of games: the hardest
#' shot, the fastest skater, the most distance skated (skater, team and
#' league), the most shots on goal and the most high-danger saves.
#'
#' @return A named list: `info` (the date and number of games) and a
#'   one-row tibble per standout.
#' @export
#' @examplesIf interactive()
#' nhl_edge_by_the_numbers()$max_skating_speed_skater
nhl_edge_by_the_numbers <- function() {
  raw <- fetch_json(api_url("web", "edge", "by-the-numbers", "now"))
  out <- list(info = tibble::tibble(game_date = as.Date(raw$gameDate %||% NA), games = raw$games %||% NA))
  for (k in setdiff(names(raw), c("games", "gameDate"))) {
    v <- raw[[k]]
    out[[to_snake(k)]] <- if (is_record_list(v)) records_to_tibble(v) else records_to_tibble(list(v))
  }
  out
}
