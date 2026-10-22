#' The NHL stats API
#'
#' The API behind NHL.com/stats: any report it has (`"skater/summary"`,
#' `"skater/realtime"`, `"skater/timeonice"`, `"skater/bios"`,
#' `"goalie/summary"`, `"team/summary"` and many more; see
#' [nhl_stats_reports()]), by season or game by game, filtered and sorted.
#'
#' Filters are the API's own Cayenne expressions, joined with `and`:
#' `filter = "teamAbbrevs='EDM'"`, `filter = "gamesPlayed>=20"`.
#'
#' Every season back to 1917-18 is there, but not every column: shots and
#' plus/minus start in 1959-60, ice time in 1997-98, hits in 2005-06.
#' [nhl_stat_eras()] has each column's first season, and sorting by one for
#' seasons before it says so.
#'
#' @param report The report, e.g. `"skater/summary"`.
#' @param season Season (see [nhl_season()]); `NULL` for the current one, or
#'   a vector of two for a range.
#' @param game_type `"regular"`, `"playoffs"` or `"preseason"`.
#' @param filter Extra Cayenne expressions, a character vector.
#' @param sort Column to sort by, descending; prefix with `"+"` for ascending.
#' @param limit Rows to return; `-1` for all.
#' @param aggregate `TRUE` sums a range of seasons into one row per player.
#' @param by_game `TRUE` for one row per player per game.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' nhl_stats("skater/summary", "2025-26", sort = "points", limit = 10)
#' nhl_stats("goalie/summary", filter = "gamesPlayed>=20", sort = "+goalsAgainstAverage")
#' nhl_stats("skater/realtime", c(2015, 2025), aggregate = TRUE, sort = "hits", limit = 20)
#' nhl_stats("skater/summary", "1981-82", sort = "points", limit = 5)
nhl_stats <- function(report = "skater/summary", season = NULL, game_type = "regular", filter = NULL,
                      sort = NULL, limit = -1, aggregate = FALSE, by_game = FALSE) {
  seasons <- if (is.null(season)) nhl_season() else vapply(season, nhl_season, numeric(1))
  season_expr <- if (length(seasons) == 2) sprintf("seasonId>=%s and seasonId<=%s", min(seasons), max(seasons))
                 else sprintf("seasonId=%s", seasons)
  if (!is.null(sort)) stat_era_check(report, to_snake(sub("^[+-]", "", sort)), seasons)
  cayenne <- paste(c(season_expr, sprintf("gameTypeId=%d", nhl_game_type(game_type)), filter), collapse = " and ")
  q <- list(isAggregate = tolower(aggregate), isGame = tolower(by_game), limit = limit, start = 0, cayenneExp = cayenne)
  if (!is.null(sort)) {
    dir <- if (startsWith(sort, "+")) "ASC" else "DESC"
    q$sort <- jsonlite::toJSON(list(list(property = sub("^[+-]", "", sort), direction = dir)), auto_unbox = TRUE)
  }
  raw <- fetch_json(paste0(api_base("stats"), "/", report), query = q)
  front(records_to_tibble(raw$data), c("player_id", "skater_full_name", "goalie_full_name", "team_id", "team_full_name",
                                       "season_id", "game_id", "game_date", "team_abbrevs", "position_code", "games_played"))
}

#' @rdname nhl_stats
#' @return For `nhl_stats_reports()`, a tibble of the reports the API offers.
#' @export
nhl_stats_reports <- function() {
  raw <- fetch_json(api_url("stats", "config"))
  rows <- list()
  for (group in c("playerReportData", "goalieReportData", "teamReportData")) {
    kind <- sub("ReportData$", "", group)
    for (rep in names(raw[[group]])) {
      rows[[length(rows) + 1]] <- tibble::tibble(type = if (kind == "player") "skater" else kind, report = rep,
                                                 path = paste0(if (kind == "player") "skater" else kind, "/", rep))
    }
  }
  bind_rows_fill(rows)
}

#' Teams, seasons and franchises
#'
#' Reference tables from the stats API.
#'
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' nhl_teams()
#' nhl_seasons()
nhl_teams <- function() records_to_tibble(fetch_json(api_url("stats", "team"))$data)

#' @rdname nhl_teams
#' @export
nhl_seasons <- function() records_to_tibble(fetch_json(api_url("stats", "season"))$data)

#' @rdname nhl_teams
#' @export
nhl_franchises <- function() records_to_tibble(fetch_json(api_url("stats", "franchise"))$data)

#' The NHL records API
#'
#' records.nhl.com: franchise and player records, every draft pick ever,
#' officials, coaches' careers and more. `resource` is the API's name for a
#' table (`"officials"`, `"coach-career-records"`, `"draft"`,
#' `"franchise-team-totals"`, `"player"`, `"skater-career-scoring-regular-season"`, ...).
#'
#' @param resource The table.
#' @param filter A Cayenne expression, e.g. `"draftYear=2015"`.
#' @param limit Rows to return; `NULL` for the API's default.
#' @param include Related fields to join in, e.g. `"player.lastName"` or
#'   `"draftTeam.triCode"`; they come back as columns (`player_last_name`).
#' @return A tibble.
#' @seealso [nhl_records_catalog()] for every table and what it holds.
#' @export
#' @examplesIf interactive()
#' nhl_records("officials")
#' nhl_records("draft", filter = "draftYear=2015 and roundNumber=1")
#' nhl_records("draft-lottery-picks", include = c("player.lastName", "draftTeam.triCode"))
nhl_records <- function(resource, filter = NULL, limit = NULL, include = NULL) {
  query <- list(cayenneExp = filter, limit = limit)
  if (length(include)) query <- c(query, stats::setNames(as.list(include), rep("include", length(include))))
  raw <- fetch_json(api_url("records", resource), query = query)
  records_to_tibble(raw$data %||% list())
}

#' The draft
#'
#' `nhl_draft_rankings()` is NHL Central Scouting's list for a draft
#' (category 1: North American skaters, 2: international skaters,
#' 3: North American goalies, 4: international goalies).
#' `nhl_draft_picks()` is every pick of a draft, or of one round.
#'
#' @param year Draft year; `NULL` for the current one.
#' @param category Central Scouting category, 1 to 4.
#' @param round `"all"` or a round number.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' nhl_draft_rankings(2026)
#' nhl_draft_picks(2015, round = 1)
nhl_draft_rankings <- function(year = NULL, category = 1) {
  path <- if (is.null(year)) list("draft", "rankings", "now") else list("draft", "rankings", year, category)
  raw <- fetch_json(do.call(api_url, c(list("web"), path)))
  out <- records_to_tibble(raw$rankings %||% list())
  if (nrow(out)) { out$draft_year <- raw$draftYear; out$category <- raw$categoryKey }
  front(out, c("draft_year", "category", "final_rank", "midterm_rank", "first_name", "last_name", "position_code"))
}

#' @rdname nhl_draft_rankings
#' @export
nhl_draft_picks <- function(year = NULL, round = "all") {
  path <- if (is.null(year)) list("draft", "picks", "now") else list("draft", "picks", year, round)
  raw <- fetch_json(do.call(api_url, c(list("web"), path)))
  out <- records_to_tibble(raw$picks %||% list())
  if (nrow(out)) out$draft_year <- raw$draftYear
  front(out, c("draft_year", "round", "pick_in_round", "overall_pick", "team_abbrev", "first_name", "last_name", "position_code"))
}
