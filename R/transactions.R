#' Contracts and trades
#'
#' NHL contract and trade data from Sportsnet's stats API, which publishes
#' PuckPedia's tracker (the NHL's own APIs have none):
#'
#' * `nhl_signings()`: every contract signed in a calendar year: the player,
#'   the club, the term and total value, the average annual value, whether he
#'   signed as an RFA or UFA and what he will be when it ends, and any
#'   no-trade or no-movement clause. With `by_season = TRUE`, one row per
#'   season of each contract: cap hit, base salary, signing and performance
#'   bonuses, the clause that season, and the cap hit as a share of that
#'   season's salary cap.
#' * `nhl_trades()`: every trade since 2020-21, one row per trade, or with
#'   `assets = TRUE` one row per player or pick moved: who got him, his cap
#'   hit and how much was retained, his contract's term and expiry, and for a
#'   pick its year, round and original club.
#'
#' Signings are fullest from 2025 on (a few dozen a year before that).
#'
#' @param year Calendar year the contracts were signed; `NULL` for this year.
#' @param by_season One row per season of each contract.
#' @param season Season (see [nhl_season()]) or seasons the trades were made
#'   in; `NULL` for every one.
#' @param assets One row per player or pick moved, instead of per trade.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' s <- nhl_signings(2026)
#' s <- s[order(-s$aav), ]
#' s[, c("player_name", "team", "contract_length", "aav", "signing_status", "clause")]
#'
#' # Cap hits season by season:
#' nhl_signings(2026, by_season = TRUE)
#'
#' trades <- nhl_trades("2025-26", assets = TRUE)
#' players <- trades[trades$asset_type == "player", ]
#' players[, c("trade_date", "team", "player_name", "cap_hit", "retained_hit")]
nhl_signings <- function(year = NULL, by_season = FALSE) {
  year <- year %||% as.numeric(format(Sys.Date(), "%Y"))
  raw <- sportsnet_all("signings", list(league = "nhl", signing_year = year))
  if (!length(raw)) return(tibble::tibble())
  out <- tibble::tibble(
    signing_id = vapply(raw, function(s) as.character(s$signing_id %||% NA), character(1)),
    signing_date = as.Date(vapply(raw, function(s) s$signing_date %||% NA_character_, character(1))),
    player_name = trimws(paste(vapply(raw, function(s) trimws(s$player_first_name %||% ""), character(1)),
                               vapply(raw, function(s) trimws(s$player_last_name %||% ""), character(1)))),
    player_id = num_or_na(raw, "player_nhl_id"),
    position = chr_or_na(raw, "player_position"),
    age = num_or_na(raw, "player_age"),
    team_id = num_or_na(raw, "signing_team_nhl_id"),
    team = nhl_code(num_or_na(raw, "signing_team_nhl_id"), chr_or_na(raw, "signing_team_short_code")),
    contract_length = num_or_na(raw, "contract_length"),
    contract_value = num_or_na(raw, "contract_value"),
    signing_status = chr_or_na(raw, "signing_status"),
    expiry_status = chr_or_na(raw, "expiry_status"),
    contract_end = chr_or_na(raw, "contract_end"),
    clause = chr_or_na(raw, "current_year_clause"),
    clause_detail = chr_or_na(raw, "contract_description"),
    terminated = vapply(raw, function(s) isTRUE(s$terminated), logical(1)),
    career_earnings = num_or_na(raw, "player_career_earnings"),
    article_url = chr_or_na(raw, "article_url")
  )
  out$aav <- out$contract_value / out$contract_length
  out <- front(out, c("signing_date", "player_name", "player_id", "position", "age", "team", "contract_length",
                      "contract_value", "aav"))
  if (!by_season) return(out[order(out$signing_date, decreasing = TRUE), ])

  years <- lapply(seq_along(raw), function(i) {
    ys <- raw[[i]]$years %||% list()
    if (!length(ys)) return(NULL)
    tibble::tibble(
      signing_id = out$signing_id[[i]],
      season = vapply(ys, function(y) nhl_season(y$season %||% NA_character_), numeric(1)),
      cap_hit = vapply(ys, function(y) as.numeric(y$cap_hit %||% NA), numeric(1)),
      base_salary = vapply(ys, function(y) as.numeric(y$base_salary %||% NA), numeric(1)),
      signing_bonus = vapply(ys, function(y) as.numeric(y$s_bonuses %||% NA), numeric(1)),
      performance_bonus = vapply(ys, function(y) as.numeric(y$p_bonuses %||% NA), numeric(1)),
      season_clause = vapply(ys, function(y) y$clause %||% NA_character_, character(1)),
      cap_pct = vapply(ys, function(y) as.numeric(y$percentage_of_season_salary_cap %||% NA), numeric(1))
    )
  })
  seasons <- bind_rows_fill(years)
  if (!nrow(seasons)) return(seasons)
  seasons$season_clause[seasons$season_clause %in% ""] <- NA
  keep <- c("signing_id", "signing_date", "player_name", "player_id", "position", "team", "contract_length", "aav")
  joined <- merge(out[, keep], seasons, by = "signing_id", sort = FALSE)
  tibble::as_tibble(joined[order(joined$signing_date, joined$player_name, joined$season, decreasing = c(TRUE, FALSE, FALSE),
                                 method = "radix"), ])
}

#' @rdname nhl_signings
#' @export
nhl_trades <- function(season = NULL, assets = FALSE) {
  raw <- sportsnet_all("trades", list(league = "nhl"))
  if (!is.null(season)) {
    start <- vapply(season, function(s) as.numeric(substr(nhl_season(s), 1, 4)), numeric(1))
    raw <- Filter(function(t) as.numeric(t$season %||% NA) %in% start, raw)
  }
  if (!length(raw)) return(tibble::tibble())
  season_id <- function(t) as.numeric(sprintf("%d%d", as.integer(t$season), as.integer(t$season) + 1L))
  if (!assets) {
    out <- tibble::tibble(
      trade_id = chr_or_na(raw, "trade_id"),
      trade_date = as.Date(chr_or_na(raw, "trade_date")),
      season = vapply(raw, season_id, numeric(1)),
      teams = vapply(raw, function(t) paste(vapply(t$teams, function(x) nhl_code(as.numeric(x$nhl_team_id %||% NA),
                                                                                    x$short_code %||% "?"), character(1)),
                                            collapse = ", "), character(1)),
      details = chr_or_na(raw, "trade_details"),
      article_url = chr_or_na(raw, "article_url")
    )
    return(out[order(out$trade_date, decreasing = TRUE), ])
  }
  rows <- list()
  for (t in raw) {
    for (tm in t$teams %||% list()) {
      for (a in tm$assets %||% list()) {
        p <- a$player %||% list()
        rows[[length(rows) + 1]] <- tibble::tibble(
          trade_id = as.character(t$trade_id %||% NA), trade_date = as.Date(t$trade_date %||% NA),
          season = season_id(t), team = nhl_code(as.numeric(tm$nhl_team_id %||% NA), tm$short_code %||% NA_character_),
          team_id = as.numeric(tm$nhl_team_id %||% NA), asset_type = a$asset_type %||% NA_character_,
          player_name = if (length(p)) trimws(paste(p$first_name %||% "", p$last_name %||% "")) else NA_character_,
          player_id = as.numeric(p$nhl_id %||% NA), position = p$position %||% NA_character_,
          age = as.numeric(p$age %||% NA), cap_hit = as.numeric(a$cap_hit %||% NA),
          acquired_cap_hit = as.numeric(a$acquired_cap_hit %||% NA), retained_hit = as.numeric(a$retained_hit %||% NA),
          contract_length = as.numeric(a$contract_length %||% NA), year_of_contract = as.numeric(a$year_of_contract %||% NA),
          expiry_status = a$expiry_status %||% NA_character_, expiry_year = a$expiry_year %||% NA_character_,
          pick_year = as.numeric(a$draft_year %||% NA), pick_round = as.numeric(a$draft_round %||% NA),
          pick_original_team = if (is.null(a$draft_year)) NA_character_
                               else nhl_code(as.numeric(a$original_team_nhl_id %||% NA), a$original_team_short_name %||% NA_character_),
          pick_overall = as.numeric(a$overall_position %||% NA),
          pick_conditions = if (nzchar(a$conditions %||% "")) a$conditions else NA_character_
        )
      }
    }
  }
  out <- bind_rows_fill(rows)
  if (!nrow(out)) return(out)
  out[order(out$trade_date, out$trade_id, decreasing = TRUE, method = "radix"), ]
}

#' Transactions and injuries, from ESPN
#'
#' * `espn_transactions()`: every NHL roster move ESPN logs in a calendar
#'   year: signings (with term), trades, waivers, call-ups and assignments,
#'   injured-reserve moves, hirings and firings. `action` is the first verb
#'   of the move; one entry can describe several moves.
#' * `espn_injuries()`: every injured player now: status, the injury, when it
#'   was reported and ESPN's expected return.
#'
#' @param year Calendar year; `NULL` for this year.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' tx <- espn_transactions()
#' tx[tx$action == "signed", ]
#' espn_injuries()
espn_transactions <- function(year = NULL) {
  year <- year %||% as.numeric(format(Sys.Date(), "%Y"))
  url <- paste0(api_base("espn_site"), "/transactions")
  rows <- list(); page <- 1
  repeat {
    raw <- fetch_json(url, query = list(season = year, limit = 1000, page = page))
    rows <- c(rows, raw$transactions %||% list())
    if (page >= (raw$pageCount %||% 1)) break
    page <- page + 1
  }
  if (!length(rows)) return(tibble::tibble())
  out <- tibble::tibble(
    date = as.Date(substr(chr_or_na(rows, "date"), 1, 10)),
    team = vapply(rows, function(r) r$team$abbreviation %||% NA_character_, character(1)),
    team_name = vapply(rows, function(r) r$team$displayName %||% NA_character_, character(1)),
    description = chr_or_na(rows, "description")
  )
  out$action <- tolower(sub("[^A-Za-z-].*$", "", out$description))
  out <- front(out, c("date", "team", "action", "description"))
  out[order(out$date, decreasing = TRUE), ]
}

#' @rdname espn_transactions
#' @export
espn_injuries <- function() {
  raw <- fetch_json(paste0(api_base("espn_site"), "/injuries"))
  rows <- list()
  for (club in raw$injuries %||% list()) {
    for (i in club$injuries %||% list()) {
      a <- i$athlete %||% list()
      link <- (a$links %||% list(list()))[[1]]$href %||% ""
      rows[[length(rows) + 1]] <- tibble::tibble(
        team = a$team$abbreviation %||% NA_character_,
        player_name = a$displayName %||% NA_character_,
        espn_id = suppressWarnings(as.numeric(sub(".*/id/([0-9]+).*", "\\1", link))),
        position = a$position$abbreviation %||% NA_character_,
        status = i$status %||% NA_character_,
        injury = i$details$type %||% NA_character_,
        date = as.Date(substr(i$date %||% NA_character_, 1, 10)),
        return_date = as.Date(i$details$returnDate %||% NA_character_),
        comment = i$longComment %||% NA_character_
      )
    }
  }
  out <- bind_rows_fill(rows)
  if (!nrow(out)) return(out)
  out[order(out$team, out$player_name), ]
}

# The NHL's abbreviation for a club from its NHL team id, falling back to the
# source's own code (Sportsnet writes Nashville as NAS).
nhl_code <- function(team_id, fallback) {
  info <- nhl_team_info()
  out <- info$abbrev[match(team_id, info$team_id)]
  fallback[fallback %in% ""] <- NA
  ifelse(is.na(out), fallback, out)
}

# Every page of a Sportsnet stats API list.
sportsnet_all <- function(path, query, per_page = 1000) {
  url <- paste0(api_base("sportsnet"), "/", path)
  out <- list(); offset <- 0
  repeat {
    raw <- fetch_json(url, query = c(query, list(per_page = per_page, offset = offset)))
    data <- raw$data %||% list()
    out <- c(out, data)
    offset <- offset + length(data)
    if (!length(data) || offset >= (raw$total %||% 0)) break
  }
  out
}

chr_or_na <- function(rows, key) {
  vapply(rows, function(r) { v <- r[[key]]; if (is.null(v) || !nzchar(as.character(v))) NA_character_ else as.character(v) },
         character(1))
}
num_or_na <- function(rows, key) vapply(rows, function(r) suppressWarnings(as.numeric(r[[key]] %||% NA)), numeric(1))
