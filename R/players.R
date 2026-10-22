#' Players
#'
#' `nhl_player()` is a player's page: biography, his featured and career
#' numbers, every season he played (`season_totals`), his last five games and
#' his awards. `nhl_player_game_log()` is every game of a season.
#' `nhl_player_search()` finds players by name, active or retired.
#'
#' @param player_id NHL player id, e.g. `8478402` (Connor McDavid).
#' @return `nhl_player()`: a named list of tibbles (`bio`, `season_totals`,
#'   `last_5_games`, `awards`, `career_totals`); the others: a tibble.
#' @export
#' @examplesIf interactive()
#' p <- nhl_player(8478402)
#' p$bio
#' nhl <- p$season_totals[p$season_totals$league_abbrev == "NHL", ]
#' nhl[, c("season", "games_played", "goals", "points")]
#' nhl_player_game_log(8478402, "2025-26")
#' nhl_player_search("hughes")
nhl_player <- function(player_id) {
  raw <- fetch_json(api_url("web", "player", player_id, "landing"))
  tables <- c("seasonTotals", "last5Games", "awards", "currentTeamRoster", "shopLink", "twitterLink", "watchLink",
              "featuredStats", "careerTotals", "badges")
  bio <- records_to_tibble(list(raw[setdiff(names(raw), tables)]))
  list(
    bio = bio,
    season_totals = records_to_tibble(raw$seasonTotals %||% list()),
    last_5_games = records_to_tibble(raw$last5Games %||% list()),
    awards = records_to_tibble(raw$awards %||% list()),
    career_totals = records_to_tibble(list(raw$careerTotals %||% list(none = NA)))
  )
}

#' @rdname nhl_player
#' @param season Season (see [nhl_season()]); `NULL` for the current one.
#' @param game_type `"regular"` or `"playoffs"`.
#' @export
nhl_player_game_log <- function(player_id, season = NULL, game_type = "regular") {
  raw <- fetch_json(api_url("web", "player", player_id, "game-log", nhl_season(season), nhl_game_type(game_type)))
  log <- records_to_tibble(raw$gameLog %||% list())
  if (nrow(log)) {
    log$game_date <- as.Date(log$game_date)
    log$toi_seconds <- toi_seconds(log)
    log$player_id <- player_id
  }
  front(log, c("player_id", "game_id", "game_date", "team_abbrev", "home_road_flag", "opponent_abbrev"))
}

#' @rdname nhl_player
#' @param query A name, or part of one.
#' @param active `TRUE` for current players only, `FALSE` for retired ones,
#'   `NULL` for both.
#' @param limit Most results to return.
#' @export
nhl_player_search <- function(query, active = NULL, limit = 20) {
  q <- list(culture = "en-us", limit = limit, q = query)
  if (!is.null(active)) q$active <- tolower(as.character(active))
  out <- records_to_tibble(fetch_json(api_url("search", "search", "player"), query = q))
  if (nrow(out)) out$player_id <- as.numeric(out$player_id)
  out
}

#' Rosters and prospects
#'
#' A club's roster for a season (forwards, defencemen and goalies with
#' height, weight, birthplace and sweater number), or its prospects.
#'
#' @param team Club abbreviation (`"EDM"`).
#' @param season Season (see [nhl_season()]), or `"current"`.
#' @return A tibble, one row per player.
#' @export
#' @examplesIf interactive()
#' nhl_roster("EDM")
#' nhl_roster("EDM", "2015-16")
#' nhl_prospects("CHI")
nhl_roster <- function(team, season = "current") {
  s <- if (identical(season, "current") || is.null(season)) "current" else nhl_season(season)
  roster_groups(fetch_json(api_url("web", "roster", team_lookup(team), s)), team)
}

#' @rdname nhl_roster
#' @export
nhl_prospects <- function(team) {
  roster_groups(fetch_json(api_url("web", "prospects", team_lookup(team))), team)
}

roster_groups <- function(raw, team) {
  groups <- c(forwards = "F", defensemen = "D", goalies = "G")
  out <- bind_rows_fill(lapply(names(groups), function(g) {
    d <- records_to_tibble(raw[[g]] %||% list())
    if (nrow(d)) d$position_group <- groups[[g]]
    d
  }))
  if (!nrow(out)) return(out)
  out$team <- team_lookup(team)
  out$full_name <- paste(out$first_name, out$last_name)
  front(out, c("team", "id", "full_name", "first_name", "last_name", "sweater_number", "position_code", "position_group"))
}

#' Club stats
#'
#' Every skater's and goalie's numbers for one club and season.
#'
#' @inheritParams nhl_roster
#' @param game_type `"regular"` or `"playoffs"`.
#' @return A list of tibbles: `skaters` and `goalies`.
#' @export
#' @examplesIf interactive()
#' nhl_team_stats("EDM", "2025-26")$skaters
nhl_team_stats <- function(team, season = NULL, game_type = "regular") {
  raw <- fetch_json(api_url("web", "club-stats", team_lookup(team), nhl_season(season), nhl_game_type(game_type)))
  add_team <- function(d) { if (nrow(d)) d$team <- team_lookup(team); front(d, c("team", "player_id")) }
  list(skaters = add_team(records_to_tibble(raw$skaters %||% list())),
       goalies = add_team(records_to_tibble(raw$goalies %||% list())))
}

#' Stat leaders
#'
#' The league leaders the NHL's stats pages open with: for skaters goals,
#' assists, points, plus-minus, power-play and shorthanded goals, penalty
#' minutes, faceoffs and ice time; for goalies wins, shutouts, save
#' percentage and goals-against average.
#'
#' @param type `"skater"` or `"goalie"`.
#' @param categories Categories to return, e.g. `c("goals", "points")`;
#'   `NULL` for all.
#' @param limit Players per category.
#' @inheritParams nhl_team_stats
#' @return A tibble: `category`, `rank` and the player's details and value.
#' @export
#' @examplesIf interactive()
#' nhl_stat_leaders("skater", categories = "goals", limit = 10)
nhl_stat_leaders <- function(type = c("skater", "goalie"), season = NULL, game_type = "regular", categories = NULL, limit = NULL) {
  type <- match.arg(type)
  q <- list(limit = limit)
  if (!is.null(categories)) q$categories <- paste(categories, collapse = ",")
  raw <- fetch_json(api_url("web", paste0(type, "-stats-leaders"), nhl_season(season), nhl_game_type(game_type)), query = q)
  bind_rows_fill(lapply(names(raw), function(cat) {
    d <- records_to_tibble(raw[[cat]])
    if (!nrow(d)) return(d)
    d$category <- to_snake(cat)
    d$rank <- seq_len(nrow(d))
    front(d, c("category", "rank", "id", "first_name", "last_name", "team_abbrev", "value"))
  }))
}

#' Headshot, logo and jersey URLs
#'
#' Image URLs on the NHL's asset server: a player's headshot in a given
#' season's sweater (or his latest), a club's logo, and its jersey texture,
#' a 96-pixel square of sweater mesh in the club's colour that tiles
#' seamlessly (NHL.com fills player cards with it); `"NHL"` gives the
#' league's own.
#'
#' @param player_id NHL player id.
#' @param team Club abbreviation; needed with `season`.
#' @param season Season for the headshot; `NULL` for the latest one.
#' @param variant `"light"` (for light backgrounds) or `"dark"`.
#' @return A URL.
#' @seealso [nhl_broadcasts()] for broadcasters' logos.
#' @export
#' @examples
#' nhl_headshot_url(8478402)
#' nhl_headshot_url(8478402, "EDM", "2016-17")
#' nhl_logo_url("EDM", "dark")
#' nhl_jersey_url("EDM")
nhl_headshot_url <- function(player_id, team = NULL, season = NULL) {
  if (is.null(season)) return(sprintf("https://assets.nhle.com/mugs/nhl/latest/%s.png", player_id))
  if (is.null(team)) cli::cli_abort("A season's headshot needs the {.arg team} he played for.")
  sprintf("https://assets.nhle.com/mugs/nhl/%s/%s/%s.png", nhl_season(season), team_lookup(team), player_id)
}

#' @rdname nhl_headshot_url
#' @export
nhl_logo_url <- function(team, variant = c("light", "dark")) {
  variant <- match.arg(variant)
  sprintf("https://assets.nhle.com/logos/nhl/svg/%s_%s.svg", team_lookup(team), variant)
}

#' @rdname nhl_headshot_url
#' @export
nhl_jersey_url <- function(team) {
  key <- if (identical(toupper(as.character(team)), "NHL")) "NHL" else team_lookup(team)
  sprintf("https://assets.nhle.com/textures/nhl/jersey/png/%s.png", key)
}
