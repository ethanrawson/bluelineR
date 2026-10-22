#' A player's bio, draft and awards
#'
#' What NHL.com's player pages read now (the `v2` player API): birthplace,
#' nationality, size and handedness, the draft (team, round, pick, junior
#' club and league), every NHL award with the season, club and his numbers
#' that year, and the long-form bio.
#'
#' @param player_id NHL player id, e.g. `8478402`.
#' @return A list: `info` (one row) and `awards` (one row per award won).
#' @export
#' @examplesIf interactive()
#' bio <- nhl_player_bio(8478402)
#' bio$info[, c("last_name", "birth_city", "draft_year", "draft_overall", "drafted_from_team")]
#' bio$awards
nhl_player_bio <- function(player_id) {
  raw <- fetch_json(paste0(sub("/v1$", "/v2", api_base("web")), "/player/", player_id, "/bio"))
  loc <- function(x) if (is.list(x)) x$default %||% NA_character_ else x %||% NA
  v <- raw$vitals %||% list()
  d <- raw$draftDetails %||% list()
  b <- raw$bio %||% list()
  info <- tibble::tibble(
    player_id = as.integer(player_id), first_name = loc(b$firstName), last_name = loc(b$lastName),
    birth_date = as.Date(v$birthDate %||% NA), birth_city = loc(v$birthCity),
    birth_state_province = loc(v$birthStateProvince), birth_country = v$birthCountry %||% NA_character_,
    nationality = v$nationality %||% NA_character_, height_in = v$heightInches %||% NA_integer_,
    weight_lb = v$weightPounds %||% NA_integer_, shoots_catches = v$shootsCatches %||% NA_character_,
    draft_year = d$year %||% NA_integer_, draft_team = d$teamAbbrev %||% NA_character_,
    draft_round = d$round %||% NA_integer_, draft_pick_in_round = d$pickInRound %||% NA_integer_,
    draft_overall = d$overallPick %||% NA_integer_, drafted_from_team = loc(d$draftedFromTeam),
    drafted_from_league = loc(d$draftedFromLeagueAbbrev), current_team = raw$currentTeam$teamAbbrev %||% NA_character_,
    action_shot = v$actionShot %||% NA_character_, bio = loc(b$about)
  )
  rows <- list()
  for (a in raw$awards %||% list()) {
    for (w in a$details %||% list(list())) {
      s <- w$stats %||% list()
      rows[[length(rows) + 1]] <- tibble::tibble(
        award = loc(a$name), short_name = loc(a$shortName), description = loc(a$description),
        # Playoff awards carry the year, the rest the season.
        season = suppressWarnings(as.integer(w$seasonWon %||% NA)),
        year_won = w$yearWon %||% (if (!is.null(w$seasonWon)) as.integer(substr(w$seasonWon, 5, 8)) else NA_integer_),
        team = w$team$teamAbbrev %||% NA_character_,
        games_played = s$gamesPlayed %||% NA_integer_, goals = s$goals %||% NA_integer_,
        assists = s$assists %||% NA_integer_, points = s$points %||% NA_integer_,
        wins = s$wins %||% NA_integer_, save_pctg = s$savePctg %||% NA_real_, gaa = s$goalsAgainstAverage %||% NA_real_
      )
    }
  }
  awards <- if (length(rows)) vctrs::vec_rbind(!!!rows) else tibble::tibble()
  if (nrow(awards)) awards <- awards[order(awards$year_won, awards$award), ]
  # Columns no award of his has (a skater's save %, a goalie's points) go.
  if (nrow(awards)) awards <- awards[, vapply(awards, function(x) !all(is.na(x)), logical(1)), drop = FALSE]
  list(info = info, awards = awards)
}

#' Two clubs side by side
#'
#' The NHL's team comparison: power play and penalty kill, faceoffs, goals
#' for and against a game and the rest of the headline numbers for two
#' clubs, each with its league rank.
#'
#' @param team_a,team_b Club abbreviations (`"EDM"`) or team ids.
#' @inheritParams nhl_team_stats
#' @return A tibble, one row per stat: each club's value and rank.
#' @export
#' @examplesIf interactive()
#' nhl_team_comparison("EDM", "TOR")
nhl_team_comparison <- function(team_a, team_b, season = NULL, game_type = "regular") {
  raw <- fetch_json(api_url("web", "team-stats-comparison", team_lookup(team_a), team_lookup(team_b),
                            nhl_season(season), nhl_game_type(game_type)))
  a <- raw$leftTeamStats %||% list()
  b <- raw$rightTeamStats %||% list()
  stats <- setdiff(names(a), grep("Rank$", names(a), value = TRUE))
  num <- function(x) if (is.null(x)) NA_real_ else as.numeric(x)
  tibble::tibble(
    stat = to_snake(stats),
    team_a = raw$leftTeam$abbrev %||% team_lookup(team_a), team_a_value = vapply(stats, function(k) num(a[[k]]), numeric(1), USE.NAMES = FALSE),
    team_a_rank = vapply(stats, function(k) num(a[[paste0(k, "Rank")]]), numeric(1), USE.NAMES = FALSE),
    team_b = raw$rightTeam$abbrev %||% team_lookup(team_b), team_b_value = vapply(stats, function(k) num(b[[k]]), numeric(1), USE.NAMES = FALSE),
    team_b_rank = vapply(stats, function(k) num(b[[paste0(k, "Rank")]]), numeric(1), USE.NAMES = FALSE)
  )
}

#' Where to watch a game
#'
#' The NHL's viewing guide for a game: the national and regional networks
#' carrying it in the US and Canada (each club's local broadcast) and the
#' streaming options out of market and abroad.
#'
#' @inheritParams nhl_pbp
#' @return A tibble, one row per broadcaster and market.
#' @export
#' @examplesIf interactive()
#' nhl_broadcasts(2026020066)
nhl_broadcasts <- function(game_id) {
  raw <- fetch_json(api_url("web", "how-to-watch", check_game_id(game_id)))
  loc <- function(x) if (is.list(x)) x$default %||% NA_character_ else x %||% NA_character_
  row <- function(p, b, team = NA_character_) tibble::tibble(
    market = p$market %||% NA_character_, countries = paste(unlist(p$countries), collapse = ","),
    team = team, broadcaster_id = b$id %||% NA_integer_, country_code = b$countryCode %||% NA_character_,
    network = b$network %||% loc(b$title), language = b$languageCode %||% NA_character_, link = loc(b$weblink)
  )
  rows <- list()
  for (p in raw$panels %||% list()) {
    for (b in p$broadcasters %||% list()) rows[[length(rows) + 1]] <- row(p, b)
    for (side in c("homeTeam", "awayTeam")) {
      t <- p[[side]]
      for (b in t$broadcasters %||% list()) rows[[length(rows) + 1]] <- row(p, b, t$abbrev %||% NA_character_)
    }
  }
  if (!length(rows)) return(tibble::tibble())
  vctrs::vec_rbind(!!!rows)
}

#' The NHL's quick standings and leaders
#'
#' The small static files NHL.com's scoreboard pages load
#' (`live.nhle.com/psr`): the standings by division, each club's power play
#' and penalty kill, and the skater (goals, assists, points, shots) and
#' goalie leaders. Quicker than the full standings and stats endpoints when
#' the headline numbers are all you need.
#'
#' @param feed `"standings"`, `"power_play"`, `"skater_leaders"` or
#'   `"goalie_leaders"`.
#' @param season Season (see [nhl_season()]); `NULL` for the current one.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' nhl_quick_stats("power_play")
#' nhl_quick_stats("skater_leaders")
nhl_quick_stats <- function(feed = c("standings", "power_play", "skater_leaders", "goalie_leaders"), season = NULL) {
  feed <- match.arg(feed)
  file <- c(standings = "standings.json", power_play = "power-play.json",
            skater_leaders = "skater-leaders.json", goalie_leaders = "goalie-leaders.json")[[feed]]
  raw <- fetch_json(api_url("psr", nhl_season(season), file))
  if (feed == "power_play") return(front(records_to_tibble(raw), c("team_abbrev")))
  # Grouped files: divisions for the standings, categories for the leaders.
  key <- if (feed == "standings") "division" else "category"
  rows <- lapply(names(raw), function(g) {
    d <- records_to_tibble(raw[[g]])
    if (nrow(d)) d[[key]] <- if (key == "category") to_snake(g) else g
    d
  })
  out <- vctrs::vec_rbind(!!!rows)
  front(out, c(key, "rank", "team_abbrev", "id", "first_name", "last_name", "team_abbrev", "value"))
}

#' NHL.com news and videos
#'
#' The stories and videos on NHL.com, newest first, from its content API:
#' headline, summary or description, date, author, tags (club and season
#' tags like `"teamid-22"`, players' tags, ...) and the address. Videos carry
#' their Brightcove id and length.
#'
#' @param tag Only items with this tag (a slug, e.g. `"teamid-22"` or
#'   `"goals"`); `NULL` for everything.
#' @param limit How many items (up to 100).
#' @param language Locale, e.g. `"en-us"` or `"fr-ca"`.
#' @return A tibble, one row per item.
#' @export
#' @examplesIf interactive()
#' nhl_news(limit = 5)
#' nhl_videos(tag = "teamid-22", limit = 5)
nhl_news <- function(tag = NULL, limit = 20, language = "en-us") nhl_content("stories", tag, limit, language)

#' @rdname nhl_news
#' @export
nhl_videos <- function(tag = NULL, limit = 20, language = "en-us") nhl_content("videos", tag, limit, language)

nhl_content <- function(kind, tag, limit, language) {
  # Built by hand: "$limit" has to reach the server as written, and httr2's
  # query builder sends it as "%24limit", which the server ignores.
  url <- paste0(api_url("content", language, kind), "?$limit=", limit,
                if (!is.null(tag)) paste0("&tags.slug=", utils::URLencode(tag, reserved = TRUE)) else "")
  raw <- fetch_json(url)
  items <- raw$items %||% list()
  if (!length(items)) return(tibble::tibble())
  str <- function(x) if (is.null(x) || (is.list(x) && !length(x))) NA_character_ else as.character(x)
  base <- if (kind == "stories") "https://www.nhl.com/news/" else "https://www.nhl.com/video/"
  out <- vctrs::vec_rbind(!!!lapply(items, function(it) {
    f <- it$fields %||% list()
    tibble::tibble(
      type = if (kind == "stories") "story" else "video", slug = str(it$slug),
      title = str(it$headline %||% f$headline %||% it$title), summary = str(it$summary %||% f$description),
      date = as.POSIXct(str(it$contentDate), format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC"),
      author = str(it$createdBy), tags = paste(vapply(it$tags %||% list(), function(t) str(t$slug), ""), collapse = ","),
      url = paste0(base, str(it$slug)),
      brightcove_id = str(f$brightcoveId), duration = str(f$duration)
    )
  }))
  out[order(out$date, decreasing = TRUE), ]
}

#' Playoff history: series records and every playoff game
#'
#' From the NHL's records site:
#'
#' * `nhl_playoff_series()`: a franchise's playoff record against each
#'   opponent, round by round: series won and lost, games, goals, and how
#'   their last meeting went.
#' * `nhl_playoff_games()`: every playoff game of a season (any season back
#'   to 1918), with the series, the game number in it, the score, the
#'   coaches, the winning and losing goalies, the three stars and the arena.
#'
#' @param team Club abbreviation (`"EDM"`) or team id.
#' @param opponent Only the record against this club; `NULL` for all.
#' @param season Season, e.g. `2024` or `"20242025"`.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' nhl_playoff_series("EDM", "FLA")
#' nhl_playoff_series("TOR")
#' nhl_playoff_games(2024)
nhl_playoff_series <- function(team, opponent = NULL) {
  out <- nhl_records("playoff-franchise-vs-team", filter = sprintf("teamId=%s", team_lookup(team, "team_id")))
  if (!is.null(opponent) && nrow(out)) out <- out[out$opponent_team_id == team_lookup(opponent, "team_id"), ]
  front(out, c("team_name", "opponent_team_name", "series_title", "series_wins", "series_losses", "games_played",
               "wins", "losses", "ties", "overtime_losses", "goals_for", "goals_against", "last_meeting_season_id",
               "last_meeting_result"))
}

#' @rdname nhl_playoff_series
#' @export
nhl_playoff_games <- function(season) {
  out <- nhl_records("yearly-playoff-series-details", filter = sprintf("season=%s", nhl_season(season)))
  if (!nrow(out)) return(out)
  out <- out[order(out$game_date %||% out$game_id), ]
  front(out, c("season", "playoff_round", "series_title", "playoff_series_letter", "game_id", "game_date",
               "home_team_id", "home_score", "visiting_team_id", "visiting_score", "period"))
}
