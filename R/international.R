#' Best-on-best international hockey
#'
#' The NHL's records of the tournaments its players have played in: the
#' Canada Cup (1976 to 1991), the World Cup of Hockey (1996, 2004, 2016), the
#' Olympics (1998 to 2014, and 2026) and the 4 Nations Face-Off (2025).
#'
#' * `nhl_international()`: every player's or club's numbers at each
#'   tournament, with skaters' ice time from 2010 on.
#' * `nhl_international_careers()`: career totals across the Canada Cup,
#'   World Cup and 4 Nations, or with `olympics = TRUE`, across the Olympics,
#'   with medals.
#' * `nhl_international_games()`: every game, with the round, score,
#'   goalies, coaches, three stars and the winning goal. The game ids work
#'   with [nhl_pbp()] and [nhl_boxscore()]: full play-by-play for the 4
#'   Nations and the 2016 World Cup, goals and penalties for the Olympics.
#'   Goals at the 4 Nations have puck and player tracking as well, for
#'   [nhl_goal_tracking()] and [animate_goal()].
#' * `nhl_international_winners()`: the game that decided each tournament,
#'   with the captains, the winning goalie and who scored the winner.
#' * `nhl_olympic_podiums()`: gold, silver and bronze at each Olympics, with
#'   captains and coaches.
#'
#' Tournaments are named by the year they were played (`year = 2026`), not
#' the NHL season they fell in.
#'
#' @param type `"skater"`, `"goalie"` or, for `nhl_international()`, `"team"`.
#' @param tournament `"olympics"`, `"world cup"`, `"canada cup"` or
#'   `"4 nations"`; `NULL` for all of them.
#' @param year Year or years the tournament was played; `NULL` for all.
#' @param olympics `TRUE` for Olympic careers and medals.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' # Scoring at the 2026 Olympics:
#' oly <- nhl_international("skater", "olympics", 2026)
#' head(oly[, c("first_name", "last_name", "tri_code", "games_played", "goals", "assists", "points")])
#'
#' # Every 4 Nations game, then the final's play-by-play:
#' games <- nhl_international_games("4 nations")
#' nhl_pbp(games$game_id[games$series_title == "Final"])
#'
#' # McDavid's overtime winner in the final, from the tracking:
#' animate_goal(nhl_goal_tracking(2024200007, 1443), "mcdavid-4-nations.mp4",
#'              goal = nhl_goal_replay(2024200007, 1443))
#'
#' nhl_international_careers("skater")
#' nhl_international_careers("goalie", olympics = TRUE)
#' nhl_international_winners()
#' nhl_olympic_podiums()
nhl_international <- function(type = c("skater", "goalie", "team"), tournament = NULL, year = NULL) {
  type <- match.arg(type)
  resource <- switch(type, skater = "international-skater-tournament-record",
                     goalie = "international-goaltender-tournament-record", team = "international-team-tournament-record")
  out <- intl_filter(intl_tag(nhl_records(resource)), tournament, year)
  out <- rename_cols(out, c(soi_total = "toi_seconds", total_seconds_on_ice = "toi_seconds"))
  # Skaters' ice time was not kept before 2010; it comes back as 0.
  if (type == "skater") out$toi_seconds[out$toi_seconds %in% 0] <- NA
  key <- switch(type, skater = -out$points, goalie = -out$wins, team = -out$wins)
  out <- out[order(out$year, out$tournament, key), ]
  front(out, c("tournament", "year", "season", "player_id", "first_name", "last_name", "position", "team_id",
               "team_name", "tri_code", "is_championship_winner", "games_played"))
}

#' @rdname nhl_international
#' @export
nhl_international_careers <- function(type = c("skater", "goalie"), olympics = FALSE) {
  type <- match.arg(type)
  resource <- sprintf("%s-%s-career-record", if (olympics) "olympic" else "international",
                      if (type == "skater") "skater" else "goaltender")
  out <- rename_cols(nhl_records(resource), c(total_seconds_on_ice = "toi_seconds"))
  out <- out[order(if (type == "skater") -out$points else -out$wins), ]
  front(out, c("player_id", "first_name", "last_name", "position", "team_name", "tournaments_played", "games_played"))
}

#' @rdname nhl_international
#' @export
nhl_international_games <- function(tournament = NULL, year = NULL) {
  out <- intl_filter(intl_tag(nhl_records("international-playoff-series-details")), tournament, year)
  if (!nrow(out)) return(out)
  teams <- nhl_records("international-team-tournament-record")
  code <- stats::setNames(teams$tri_code, teams$team_id)
  out$home_team <- unname(code[as.character(out$home_team_id)])
  out$visiting_team <- unname(code[as.character(out$visiting_team_id)])
  out$winning_team <- unname(code[as.character(out$winning_team_id)])
  out$game_date <- as.Date(substr(out$game_date, 1, 10))
  out$overtime[out$overtime %in% ""] <- NA
  out <- out[order(out$game_date, out$game_id), ]
  front(out, c("tournament", "year", "season", "game_id", "game_date", "series_title", "visiting_team", "visiting_score",
               "home_team", "home_score", "winning_team", "overtime", "arena_name"))
}

#' @rdname nhl_international
#' @export
nhl_international_winners <- function() {
  out <- intl_tag(nhl_records("international-tournament-winner"))
  if (!nrow(out)) return(out)
  out$date <- as.Date(out$date)
  out$overtime[out$overtime %in% ""] <- NA
  out <- out[order(out$date), ]
  front(out, c("tournament", "year", "season", "date", "city", "winning_tricode", "winning_score", "losing_tricode",
               "losing_score", "overtime", "game_id"))
}

#' @rdname nhl_international
#' @export
nhl_olympic_podiums <- function() {
  out <- intl_tag(nhl_records("olympic-tournament-winner"))
  if (!nrow(out)) return(out)
  out$date <- as.Date(out$date)
  out <- out[order(out$date), ]
  front(out, c("tournament", "year", "season", "date", "city", "gold_medalist_tricode", "silver_medalist_tricode",
               "bronze_medalist_tricode"))
}

# The NHL's game types for the tournaments, and the year each was played
# (the season it is filed under is not always the year it was played: the
# 2004 World Cup is in 2003-04).
intl_types <- c(`Canada Cup` = 14, `World Cup of Hockey` = 6, Olympics = 9, `4 Nations Face-Off` = 19)
intl_years <- tibble::tibble(
  game_type = c(rep(14, 5), rep(6, 3), rep(9, 6), 19),
  season = c(19761977, 19811982, 19841985, 19871988, 19911992, 19961997, 20032004, 20162017,
             19971998, 20012002, 20052006, 20092010, 20132014, 20252026, 20242025),
  year = c(1976, 1981, 1984, 1987, 1991, 1996, 2004, 2016, 1998, 2002, 2006, 2010, 2014, 2026, 2025)
)

# Adds `tournament` and `year`. The 4 Nations final is game type 20.
intl_tag <- function(d) {
  if (!nrow(d)) return(d)
  gt <- as.numeric(d$game_type)
  gt[gt == 20] <- 19
  d$tournament <- names(intl_types)[match(gt, intl_types)]
  d$tournament[is.na(d$tournament)] <- sub(" Round-Robin$", "", d$game_type_description[is.na(d$tournament)])
  k <- match(paste(gt, d$season), paste(intl_years$game_type, intl_years$season))
  d$year <- intl_years$year[k]
  later <- is.na(d$year)
  d$year[later] <- as.numeric(substr(d$season[later], 5, 8))
  d
}

intl_filter <- function(d, tournament = NULL, year = NULL) {
  if (!nrow(d)) return(d)
  if (!is.null(tournament)) d <- d[d$tournament %in% intl_tournament(tournament), ]
  if (!is.null(year)) d <- d[d$year %in% year, ]
  d
}

intl_tournament <- function(x) {
  key <- tolower(gsub("[^A-Za-z0-9]", "", x))
  out <- ifelse(grepl("olymp", key), "Olympics",
         ifelse(grepl("world", key), "World Cup of Hockey",
         ifelse(grepl("canada", key), "Canada Cup",
         ifelse(grepl("^(4|four)|nations", key), "4 Nations Face-Off", NA))))
  if (anyNA(out)) {
    cli::cli_abort("{.arg tournament} must be {.val olympics}, {.val world cup}, {.val canada cup} or {.val 4 nations}, not {.val {x[is.na(out)]}}.")
  }
  out
}

rename_cols <- function(d, map) {
  hit <- names(d) %in% names(map)
  names(d)[hit] <- map[names(d)[hit]]
  d
}
