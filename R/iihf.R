#' IIHF games: schedules, shot locations, goals and penalties
#'
#' The IIHF's live-data feed (`realtime.iihf.com`, the one behind the
#' game centre on iihf.com) has every game of its championships: the World
#' Championship, the World Juniors, the women's and under-18 Worlds and the
#' division tournaments, and the 2026 Olympics. For each game it has the
#' score by period, the team stats, every goal with its scorer, assists and
#' strength, every penalty and goalie change, and **every shot with a place
#' on the ice**: goals, saves, blocked shots and shots that missed the net.
#' Shot locations go back to the 2019 tournaments; older games have the rest.
#'
#' * `iihf_schedule()`: a tournament's games, with the ids the others take.
#' * `iihf_olympic_games()`: every game of the 2026 Olympics, men's and
#'   women's (the Olympics are not on the IIHF's schedule pages).
#' * `iihf_game()`: one game in a row: teams, final score, venue, date,
#'   attendance and how it ended.
#' * `iihf_period_stats()`: shots on goal, saves, penalty minutes, power-play
#'   time and goals and faceoffs won, for each team in each period.
#' * `iihf_shots()`: every shot, its result, who took it, and where.
#' * `iihf_events()`: goals, penalties and goalie changes in order.
#'
#' **Where shots are.** The feed places each shot on a 0-1 scale of the rink
#' (`x_raw` along it, `y_raw` across). `x` and `y` scale that to feet from
#' centre ice on a rink `length` by `width` (an NHL rink by default, which is
#' what the 2026 Olympics used; IIHF rinks can be up to 60 m by 30 m), the
#' frame [nhl_rink()] draws. Teams change ends between periods, so `x_fixed`
#' and `y_fixed` turn every shot so its team attacks to the right (each
#' team's direction in a period is the end most of its shots were taken at),
#' and `distance` (feet) and `angle` (degrees off the middle) are measured to
#' the net it attacked. The table works with [plot_shots()].
#'
#' Shot results are the feed's: `"G"` goal, `"SSG"` saved by the goalkeeper,
#' `"SSP"` saved by a player (a blocked shot, placed where it was taken) and
#' `"SPG"` past the goal (missed the net). The feed times goals only, so the
#' other shots have their period but no clock.
#'
#' iihf.com itself refuses scripted requests; `iihf_schedule()` reads the
#' same pages from its mirror at `canada-central.iihf.com`.
#'
#' @param year Year the tournament was played (the World Juniors that ran
#'   from December 2025 into January 2026 are `2026`).
#' @param event The tournament's code in iihf.com addresses: `"wm"` World
#'   Championship, `"wm20"` World Juniors, `"ww"` Women's World Championship,
#'   `"wm18"` and `"ww18"` the under-18s, and the divisions (`"wm20ia"`,
#'   `"wmia"`, ...).
#' @param game_id IIHF game id, from `iihf_schedule()` or
#'   `iihf_olympic_games()`; the 2026 Olympic gold medal game is
#'   `1010000058`.
#' @param length,width Rink length and width in feet, for `x` and `y`.
#' @return A tibble.
#' @name iihf
#' @examplesIf interactive()
#' # The 2026 Olympic final: Jack Hughes in overtime.
#' shots <- iihf_shots(1010000058)
#' shots[shots$result == "goal", c("period", "time", "team", "player_name", "x", "y", "distance")]
#' plot_shots(shots)
#' iihf_events(1010000058)
#'
#' # The 2026 World Championship, and every shot of its opening game:
#' games <- iihf_schedule(2026, "wm")
#' iihf_shots(games$game_id[1])
#'
#' # Every game of the 2026 Olympics:
#' iihf_olympic_games()
NULL

#' @rdname iihf
#' @export
iihf_schedule <- function(year, event = "wm") {
  page <- fetch_text(paste(api_base("iihf_site"), "en", "events", year, event, "schedule", sep = "/"))
  event_id <- regmatches(page, regexpr('data-eventid="[0-9]+"', page))
  event_id <- if (length(event_id)) gsub("[^0-9]", "", event_id) else NA_character_
  cards <- strsplit(page, '<div class="b-card-schedule', fixed = TRUE)[[1]][-1]
  cards <- cards[grepl("data-game-id=", cards, fixed = TRUE)]
  if (!length(cards)) {
    cli::cli_abort(c("No games on the IIHF's schedule for {.val {event}} {year}.",
                     i = "Event codes are the ones in iihf.com addresses: {.val wm}, {.val wm20}, {.val ww}, ..."),
                   class = "bluelineR_not_found")
  }
  attr_of <- function(card, name) {
    m <- regmatches(card, regexec(sprintf('data-%s=["\']([^"\']*)["\']', name), card))[[1]]
    if (length(m) > 1) m[[2]] else NA_character_
  }
  inner <- function(card, cls) {
    m <- regmatches(card, regexec(sprintf('class="[^"]*%s[^"]*"[^>]*>(?:\\s*<current-score[^>]*>)?\\s*([^<]*?)\\s*<', cls), card, perl = TRUE))[[1]]
    if (length(m) > 1 && nzchar(m[[2]])) m[[2]] else NA_character_
  }
  number <- function(card) {
    m <- regmatches(card, regexec("gamecenter/[a-z]+/[0-9]+/([0-9]+)-", card))[[1]]
    if (length(m) > 1) as.integer(m[[2]]) else NA_integer_
  }
  flag <- function(card, name) tolower(attr_of(card, name)) == "true"
  out <- tibble::tibble(
    event = event, year = as.integer(year), event_id = event_id,
    game_id = vapply(cards, attr_of, "", name = "game-id", USE.NAMES = FALSE),
    game_number = vapply(cards, number, integer(1), USE.NAMES = FALSE),
    date = as.Date(vapply(cards, attr_of, "", name = "date-utc", USE.NAMES = FALSE)),
    time_utc = vapply(cards, attr_of, "", name = "time-utc", USE.NAMES = FALSE),
    phase = vapply(cards, attr_of, "", name = "phase", USE.NAMES = FALSE),
    group = vapply(cards, attr_of, "", name = "group", USE.NAMES = FALSE),
    venue = vapply(cards, inner, "", cls = "s-arena", USE.NAMES = FALSE),
    home_team = vapply(cards, attr_of, "", name = "hometeam", USE.NAMES = FALSE),
    away_team = vapply(cards, attr_of, "", name = "guestteam", USE.NAMES = FALSE),
    home_score = suppressWarnings(as.integer(vapply(cards, inner, "", cls = "js-homescore", USE.NAMES = FALSE))),
    away_score = suppressWarnings(as.integer(vapply(cards, inner, "", cls = "js-awayscore", USE.NAMES = FALSE))),
    is_final = vapply(cards, flag, logical(1), name = "gameisfinal", USE.NAMES = FALSE),
    is_overtime = vapply(cards, flag, logical(1), name = "gameisfinalovertime", USE.NAMES = FALSE),
    is_shootout = vapply(cards, flag, logical(1), name = "gameisfinalshootout", USE.NAMES = FALSE)
  )
  # The page calls a game that went to overtime or a shootout "final
  # overtime" or "final shootout", not "final".
  out$is_final <- out$is_final | out$is_overtime | out$is_shootout
  out$group[out$group %in% ""] <- NA
  out$venue <- sub(",\\s*Group.*$", "", out$venue)
  out$home_score[!out$is_final] <- NA
  out$away_score[!out$is_final] <- NA
  out[order(out$date, out$time_utc, out$game_number), ]
}

#' @rdname iihf
#' @export
iihf_olympic_games <- function() {
  # 2026: one run of ids for both tournaments, 1010000001 (the women's
  # opener) to 1010000058 (the men's gold medal game). Read until the run ends.
  rows <- list()
  for (i in seq_len(80)) {
    raw <- tryCatch(iihf_state(1010000000 + i), bluelineR_not_found = function(e) NULL)
    if (is.null(raw)) break
    rows[[length(rows) + 1]] <- iihf_game_row(raw)
  }
  vctrs::vec_rbind(!!!rows)
}

#' @rdname iihf
#' @export
iihf_game <- function(game_id) iihf_game_row(iihf_state(game_id))

#' @rdname iihf
#' @export
iihf_period_stats <- function(game_id) {
  raw <- iihf_state(game_id)
  rows <- list()
  for (p in raw$Periods) {
    s <- p$Statistics %||% list()
    for (side in c("home", "away")) {
      k <- if (side == "home") "_H" else "_A"
      num <- function(name) suppressWarnings(as.integer(s[[paste0(name, k)]] %||% NA))
      rows[[length(rows) + 1]] <- tibble::tibble(
        game_id = as.character(raw$GameId), period = as.character(p$Period), team_side = side,
        team = if (side == "home") raw$HomeTeam$ShortTeamName else raw$AwayTeam$ShortTeamName,
        goals = suppressWarnings(as.integer(p$Score[[if (side == "home") "Home" else "Away"]] %||% NA)),
        shots_on_goal = num("SOG"), saves = num("SSG"), penalty_minutes = num("PIM"),
        power_play_seconds = clock_seconds(s[[paste0("TPP", k)]] %||% NA_character_),
        power_play_goals = num("PPG"), shorthanded_goals = num("SHG"), faceoffs_won = num("FOF")
      )
    }
  }
  out <- vctrs::vec_rbind(!!!rows)
  out$period[out$period == "TOT"] <- "total"
  out
}

#' @rdname iihf
#' @export
iihf_shots <- function(game_id, length = 200, width = 85) {
  raw <- iihf_state(game_id)
  home <- raw$HomeTeam$ShortTeamName
  away <- raw$AwayTeam$ShortTeamName
  rows <- list()
  for (p in raw$Periods) {
    for (a in p$IceRingActions %||% list()) {
      who <- iihf_athlete(a$Athlete)
      is_home <- isTRUE(a$IsExecutedByHomeTeam)
      rows[[length(rows) + 1]] <- tibble::tibble(
        game_id = as.character(raw$GameId), period = as.character(p$Period), shot_id = as.character(a$Id %||% NA),
        time = a$TimeOfPlay %||% NA_character_,
        team = a$ExecutedByShortTeamName %||% if (is_home) home else away,
        team_side = if (is_home) "home" else "away", opponent = if (is_home) away else home,
        player_id = who$player_id, sweater_number = who$sweater_number, player_name = who$player_name,
        position = who$position, shot_code = a$ShotType %||% NA_character_,
        x_raw = as.numeric(a$Coordinates$X %||% NA), y_raw = as.numeric(a$Coordinates$Y %||% NA)
      )
    }
  }
  if (!length(rows)) {
    cli::cli_inform("No shot locations for IIHF game {.val {game_id}} (the feed has them from the 2019 tournaments on).")
    return(tibble::tibble())
  }
  out <- vctrs::vec_rbind(!!!rows)
  out$result <- unname(c(G = "goal", SSG = "saved", SSP = "blocked", SPG = "missed")[out$shot_code])
  # plot_shots() and code written for nhl_pbp() read these two.
  out$type <- unname(c(goal = "goal", saved = "shot-on-goal", blocked = "blocked-shot", missed = "missed-shot")[out$result])
  out$event_team <- out$team
  out$game_seconds <- clock_seconds(out$time)
  out$x <- (out$x_raw - 0.5) * length
  out$y <- (out$y_raw - 0.5) * width
  # Each team's end in each period: the end most of its shots came from.
  key <- paste(out$period, out$team)
  right <- tapply(out$x_raw, key, stats::median, na.rm = TRUE) > 0.5
  attacks_right <- as.vector(right[key])
  out$x_fixed <- ifelse(attacks_right, out$x, -out$x)
  out$y_fixed <- ifelse(attacks_right, out$y, -out$y)
  goal_line <- length / 2 - 11
  out$distance <- sqrt((goal_line - out$x_fixed)^2 + out$y_fixed^2)
  out$angle <- atan2(abs(out$y_fixed), goal_line - out$x_fixed) * 180 / pi
  out <- front(out, c("game_id", "period", "time", "team", "team_side", "opponent", "result", "player_name", "sweater_number",
                      "position", "player_id", "x", "y", "x_fixed", "y_fixed", "distance", "angle"))
  attr(out, "source") <- "IIHF"
  out
}

#' @rdname iihf
#' @export
iihf_events <- function(game_id) {
  raw <- iihf_state(game_id)
  rows <- list()
  for (p in raw$Periods) {
    for (a in p$Actions %||% list()) {
      model <- sub("ActionModel$", "", sub(".*\\.", "", a$FullTypeName %||% ""))
      type <- if (!is.null(a$Scorer)) "goal" else switch(model,
        Penalty = "penalty", TeamPenalty = "team_penalty", GoalKeeperIn = "goalie_in", GoalKeeperOut = "goalie_out", NA_character_)
      if (is.na(type)) next
      who <- iihf_athlete(a$Scorer %||% a$Athlete %||% a$GoalTender)
      a1 <- iihf_athlete(a$Assistant1)
      a2 <- iihf_athlete(a$Assistant2)
      desc <- a$Displays[["_default"]]
      rows[[length(rows) + 1]] <- tibble::tibble(
        game_id = as.character(raw$GameId), period = as.character(p$Period), time = a$TimeOfPlay %||% NA_character_,
        type = type, team = a$ExecutedByShortTeamName %||% NA_character_,
        player_name = who$player_name, sweater_number = who$sweater_number, player_id = who$player_id,
        assist_1_name = a1$player_name, assist_1_id = a1$player_id,
        assist_2_name = a2$player_name, assist_2_id = a2$player_id,
        situation = if (is.null(a$SituationType) || !nzchar(a$SituationType)) NA_character_ else a$SituationType,
        penalty_minutes = suppressWarnings(as.integer(a$PenaltyTimeMinutes %||% NA)),
        infraction = a$PenaltyCode %||% NA_character_,
        home_score = suppressWarnings(as.integer(a$NewScore$Home %||% NA)),
        away_score = suppressWarnings(as.integer(a$NewScore$Away %||% NA)),
        description = paste(stats::na.omit(c(desc$Title, desc$Description)), collapse = ": ")
      )
    }
  }
  out <- vctrs::vec_rbind(!!!rows)
  if (is.null(out) || !nrow(out)) return(tibble::tibble())
  out$game_seconds <- clock_seconds(out$time)
  out[order(out$game_seconds, match(out$type, c("goal", "penalty", "team_penalty", "goalie_out", "goalie_in"))), ]
}

# One game's whole state; the feed answers "null" for an id it doesn't know.
iihf_state <- function(game_id) {
  game_id <- as.character(game_id)
  if (!grepl("^[0-9]+$", game_id)) cli::cli_abort("{.arg game_id} should be an IIHF game id, like {.val 1010000058}.")
  raw <- fetch_json(api_url("iihf", "GetLatestState", game_id))
  if (is.null(raw) || is.null(raw$GameId)) {
    cli::cli_abort("The IIHF feed has no game {.val {game_id}}.", class = "bluelineR_not_found")
  }
  raw
}

iihf_game_row <- function(raw) {
  dt <- raw$EventDateTime %||% list()
  periods <- vapply(raw$Periods %||% list(), function(p) as.character(p$Period %||% ""), "")
  shots <- sum(vapply(raw$Periods %||% list(), function(p) length(p$IceRingActions %||% list()), integer(1)))
  tibble::tibble(
    game_id = as.character(raw$GameId), event_id = as.character(raw$EventId %||% NA),
    game_number = suppressWarnings(as.integer(raw$GameNumber %||% NA)), gender = raw$Gender %||% NA_character_,
    date = as.Date(as.character(dt$Value %||% NA), format = "%Y%m%d"),
    home_team = raw$HomeTeam$ShortTeamName %||% NA_character_, away_team = raw$AwayTeam$ShortTeamName %||% NA_character_,
    home_name = raw$HomeTeam$LongTeamName %||% NA_character_, away_name = raw$AwayTeam$LongTeamName %||% NA_character_,
    home_score = suppressWarnings(as.integer(raw$CurrentScore$Home %||% NA)),
    away_score = suppressWarnings(as.integer(raw$CurrentScore$Away %||% NA)),
    ended_in = if ("SO" %in% periods) "shootout" else if (any(grepl("^OT", periods))) "overtime" else "regulation",
    status = raw$Status %||% NA_character_, venue = raw$Venue$Name %||% NA_character_,
    attendance = suppressWarnings(as.integer(raw$Spectators %||% NA)), shots_located = shots
  )
}

# The feed's athlete record as the package's columns. Family names come in
# capitals ("MacKINNON"); the reporting name keeps the Mc and Mac.
iihf_athlete <- function(a) {
  if (is.null(a)) return(list(player_id = NA_character_, sweater_number = NA_integer_, player_name = NA_character_, position = NA_character_))
  given <- a$GivenName %||% ""
  family <- trimws(sub(paste0("\\s+", given, "$"), "", a$ReportingName %||% a$FamilyName %||% ""))
  nice <- function(w) {
    pre <- regmatches(w, regexpr("^(Mac|Mc|O'|D')", w))
    if (!length(pre)) pre <- ""
    rest <- substring(w, nchar(pre) + 1)
    rest <- gsub("(^|-)(\\w)(\\w*)", "\\1\\U\\2\\L\\3", tolower(rest), perl = TRUE)
    paste0(pre, rest)
  }
  family <- paste(vapply(strsplit(family, " ", fixed = TRUE)[[1]], nice, ""), collapse = " ")
  list(player_id = as.character(a$IH_Athlete_Id %||% NA), sweater_number = suppressWarnings(as.integer(a$Number %||% NA)),
       player_name = trimws(paste(given, family)), position = a$Position %||% NA_character_)
}
