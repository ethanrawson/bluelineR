#' DraftKings odds and player props, from ESPN
#'
#' ESPN's NHL odds come from DraftKings, and its APIs (unlike DraftKings'
#' own, which refuse requests from servers) are open:
#'
#' * `espn_odds()`: every game's moneyline, puck line and total, opening and
#'   current, with the no-vig chance of each side.
#' * `espn_props()`: DraftKings' player props for a day's games, about 500
#'   a game: shots on goal, points, assists, saves, anytime and first
#'   goalscorer, the "2+ shots" style milestones, power-play points, and each
#'   club's goal total. Each over/under comes as one row with both prices.
#'   With `nhl_ids = TRUE` every player gets his NHL id, for joining to the
#'   rest of the package.
#'
#' ESPN lists an over/under as two entries without naming the sides, over
#' first: in every pair checked against the same player's milestone prices
#' (October 2026), the first entry was the over. Players come as ESPN ids and
#' are matched to NHL rosters by club, sweater number and surname, then by
#' name. ESPN drops a game's odds once it starts.
#'
#' @param date A date (or `"YYYY-MM-DD"`); `NULL` for today.
#' @param nhl_ids Add each player's NHL id (four more requests a game).
#' @return A tibble.
#' @name espn_odds
#' @seealso [devig()] for the no-vig chance of any pair of prices.
#' @examplesIf interactive()
#' espn_odds()
#' props <- espn_props()
#' props[props$market == "Total Shots on Goal", c("player_name", "team", "line", "over", "under")]
NULL

#' @rdname espn_odds
#' @export
espn_odds <- function(date = NULL) {
  events <- espn_events(date)
  rows <- lapply(events, function(e) {
    comp <- e$competitions[[1]]
    sides <- espn_sides(comp)
    o <- Filter(function(x) identical(as.character(x$provider$id), "100"), comp$odds %||% list())
    o <- if (length(o)) o[[1]] else list()
    cur <- function(m, k, f = "odds") espn_price((m[[k]]$close %||% list())[[f]])
    opn <- function(m, k, f = "odds") espn_price((m[[k]]$open %||% list())[[f]])
    line <- function(m, k, w = "close") suppressWarnings(as.numeric(sub("^[ou]", "", (m[[k]][[w]] %||% list())$line %||% NA)))
    ml <- o$moneyline %||% list(); tot <- o$total %||% list(); pl <- o$pointSpread %||% list()
    out <- tibble::tibble(
      event_id = as.character(e$id), start_time = as.POSIXct(sub("Z$", "", e$date), format = "%Y-%m-%dT%H:%M", tz = "UTC"),
      status = comp$status$type$name %||% NA_character_,
      home_team = sides$home$abbrev, away_team = sides$away$abbrev, provider = o$provider$name %||% NA_character_,
      home_ml = cur(ml, "home"), away_ml = cur(ml, "away"), home_ml_open = opn(ml, "home"), away_ml_open = opn(ml, "away"),
      total_line = suppressWarnings(as.numeric(o$overUnder %||% line(tot, "over"))),
      over_price = cur(tot, "over"), under_price = cur(tot, "under"),
      total_line_open = line(tot, "over", "open"), over_price_open = opn(tot, "over"), under_price_open = opn(tot, "under"),
      home_puck_line = line(pl, "home"), home_puck_line_price = cur(pl, "home"), away_puck_line_price = cur(pl, "away")
    )
    out$home_win_prob <- devig(out$home_ml, out$away_ml)
    out$over_prob <- devig(out$over_price, out$under_price)
    out
  })
  if (!length(rows)) return(tibble::tibble())
  vctrs::vec_rbind(!!!rows)
}

#' @rdname espn_odds
#' @export
espn_props <- function(date = NULL, nhl_ids = TRUE) {
  rows <- list()
  for (e in espn_events(date)) {
    comp <- e$competitions[[1]]
    sides <- espn_sides(comp)
    bets <- fetch_json(paste0(api_base("espn_core"), "/events/", e$id, "/competitions/", e$id, "/odds/100/propBets"),
                       query = list(lang = "en", region = "us", limit = 1000))
    items <- bets$items %||% list()
    if (!length(items)) next
    who <- espn_roster_index(sides)
    ref_id <- function(x, what) { m <- regmatches(x %||% "", regexec(paste0(what, "/([0-9]+)"), x %||% ""))[[1]]; if (length(m) > 1) m[[2]] else NA_character_ }
    flat <- vctrs::vec_rbind(!!!lapply(items, function(it) tibble::tibble(
      athlete = ref_id(it$athlete$`$ref`, "athletes"), team_ref = ref_id(it$team$`$ref`, "teams"),
      market = it$type$name %||% NA_character_,
      line = suppressWarnings(as.numeric(it$odds$total$value %||% it$current$target$value %||% NA)),
      price = espn_price(it$odds$american$value), price_open = espn_price(it$odds$american$open),
      updated = it$lastUpdated %||% NA_character_
    )))
    # Player props, and the clubs' goal totals; period lines and the like are left out.
    flat <- flat[!is.na(flat$athlete) | flat$market %in% "Team Total Goals (Excl OT)", ]
    if (!nrow(flat)) next
    # Pairs in feed order: the first entry of an athlete's (or club's) market and line is the over.
    key <- paste(flat$athlete, flat$team_ref, flat$market, flat$line)
    flat$n <- stats::ave(seq_along(key), key, FUN = seq_along)
    flat$size <- stats::ave(seq_along(key), key, FUN = length)
    first <- flat[flat$n == 1, ]
    second <- flat[flat$n == 2, ]
    k1 <- paste(first$athlete, first$team_ref, first$market, first$line)
    k2 <- paste(second$athlete, second$team_ref, second$market, second$line)
    j <- match(k1, k2)
    two <- first$size == 2
    p <- tibble::tibble(
      event_id = as.character(e$id), home_team = sides$home$abbrev, away_team = sides$away$abbrev,
      espn_athlete_id = first$athlete, market = first$market, line = first$line,
      over = first$price, under = ifelse(two, second$price[j], NA),
      over_open = first$price_open, under_open = ifelse(two, second$price_open[j], NA),
      updated = first$updated, espn_team_id = first$team_ref
    )
    p$player_name <- who$name[match(p$espn_athlete_id, who$id)]
    p$sweater_number <- who$number[match(p$espn_athlete_id, who$id)]
    p$team <- who$team[match(p$espn_athlete_id, who$id)]
    club <- c(stats::setNames(sides$home$abbrev, sides$home$id), stats::setNames(sides$away$abbrev, sides$away$id))
    p$team[is.na(p$team)] <- unname(club[p$espn_team_id[is.na(p$team)]])
    p$over_prob <- devig(p$over, p$under)
    if (nhl_ids) p$player_id <- espn_to_nhl(p, sides)
    rows[[length(rows) + 1]] <- p
  }
  if (!length(rows)) return(tibble::tibble())
  out <- vctrs::vec_rbind(!!!rows)
  out$stat <- unname(c(`Total Shots on Goal` = "shots", `Total Points` = "points", `Total Assists` = "assists",
                       `Total Saves` = "saves", `Anytime Goalscorer` = "goals", `Total Goals` = "goals",
                       `Total Blocked Shots` = "blocks", `Total Hits` = "hits", `Total Power Play Points` = "power_play_points",
                       `Team Total Goals (Excl OT)` = "team_goals")[out$market])
  front(out, c("event_id", "team", "player_name", "player_id", "sweater_number", "market", "stat", "line", "over", "under",
               "over_prob", "over_open", "under_open"))
}

#' A player's splits, from ESPN
#'
#' ESPN's splits for a season: home and away, by opponent, by month, in wins
#' and losses, by day of the week, by conference and division and by days of
#' rest, each with games, goals, assists, points, plus-minus, shots, faceoff
#' %, power-play and shorthanded points and ice time a game.
#'
#' @param athlete_id ESPN athlete id (McDavid is `3895074`; [espn_props()]
#'   has them for every player with a prop).
#' @param season Year the season ends (`2027` for 2026-27); `NULL` for the
#'   current one.
#' @return A tibble, one row per split.
#' @export
#' @examplesIf interactive()
#' espn_player_splits(3895074)
espn_player_splits <- function(athlete_id, season = NULL) {
  raw <- fetch_json(paste0(api_base("espn_web"), "/common/v3/sports/hockey/nhl/athletes/", athlete_id, "/splits"),
                    query = list(season = season))
  cols <- to_snake(unlist(raw$names %||% list()))
  rows <- list()
  for (cat in raw$splitCategories %||% list()) {
    for (sp in cat$splits %||% list()) {
      vals <- unlist(lapply(sp$stats %||% list(), function(v) as.character(v %||% NA)))
      row <- tibble::tibble(category = to_snake(cat$name %||% NA_character_), split = sp$displayName %||% NA_character_)
      for (i in seq_along(cols)) row[[cols[i]]] <- if (i <= length(vals)) vals[[i]] else NA_character_
      rows[[length(rows) + 1]] <- row
    }
  }
  if (!length(rows)) return(tibble::tibble())
  out <- vctrs::vec_rbind(!!!rows)
  # Numbers as numbers; ice time stays "mm:ss".
  for (k in setdiff(names(out), c("category", "split"))) {
    num <- suppressWarnings(as.numeric(out[[k]]))
    if (!all(is.na(num[!is.na(out[[k]])]))) out[[k]] <- num
  }
  out
}

#' The no-vig chance of a pair of prices
#'
#' Takes the bookmaker's margin out of a two-way market by scaling both
#' implied probabilities to sum to one (the proportional method), and returns
#' the chance of the first side.
#'
#' @param first,second American prices of the two sides (`-150`, `+130`).
#'   Vectors work; a missing price gives `NA`.
#' @return The no-vig probability of `first`.
#' @export
#' @examples
#' devig(-150, 130)
#' devig(c(-110, -250), c(-110, 200))
devig <- function(first, second) {
  implied <- function(a) ifelse(is.na(a), NA_real_, ifelse(a < 0, -a / (-a + 100), 100 / (a + 100)))
  p1 <- implied(as.numeric(first)); p2 <- implied(as.numeric(second))
  p1 / (p1 + p2)
}

# --- helpers ---------------------------------------------------------------

# ESPN's abbreviations where they differ from the NHL's.
ESPN_ABBREV <- c(LA = "LAK", NJ = "NJD", SJ = "SJS", TB = "TBL", UTAH = "UTA")

espn_events <- function(date) {
  d <- format(as.Date(if (is.null(date) || identical(date, "now")) Sys.Date() else date), "%Y%m%d")
  fetch_json(paste0(api_base("espn_site"), "/scoreboard"), query = list(dates = d))$events %||% list()
}

espn_sides <- function(comp) {
  out <- list()
  for (c in comp$competitors %||% list()) {
    ab <- c$team$abbreviation %||% NA_character_
    out[[c$homeAway %||% "home"]] <- list(id = as.character(c$team$id), abbrev = unname(ifelse(ab %in% names(ESPN_ABBREV), ESPN_ABBREV[ab], ab)))
  }
  out
}

espn_price <- function(x) {
  x <- toupper(trimws(as.character(x %||% NA)))
  out <- suppressWarnings(as.numeric(sub("^\\+", "", x)))
  out[x %in% c("EVEN", "EV")] <- 100
  out
}

# Accented letters to plain ones without depending on the locale (iconv's
# TRANSLIT gives NA in a C locale): Stützle -> Stutzle.
fold_accents <- function(x) {
  # Accented letter (either case) -> plain lower-case letter, by code point.
  map <- c(
    a = "\u00e1\u00e0\u00e2\u00e4\u00e3\u00e5\u0101\u00c1\u00c0\u00c2\u00c4\u00c3\u00c5\u0100",
    c = "\u010d\u0107\u00e7\u010c\u0106\u00c7",
    d = "\u010f\u010e",
    e = "\u00e9\u00e8\u00ea\u00eb\u011b\u0113\u00c9\u00c8\u00ca\u00cb\u011a\u0112",
    i = "\u00ed\u00ec\u00ee\u00ef\u012b\u00cd\u00cc\u00ce\u00cf\u012a",
    l = "\u013e\u013a\u0142\u013d\u0139\u0141",
    n = "\u0148\u00f1\u0144\u0147\u00d1\u0143",
    o = "\u00f3\u00f2\u00f4\u00f6\u00f5\u0151\u00f8\u00d3\u00d2\u00d4\u00d6\u00d5\u0150\u00d8",
    r = "\u0159\u0158",
    s = "\u0161\u015b\u0160\u015a",
    t = "\u0165\u0164",
    u = "\u00fa\u00f9\u00fb\u00fc\u016f\u0171\u016b\u00da\u00d9\u00db\u00dc\u016e\u0170\u016a",
    y = "\u00fd\u00ff\u00dd\u0178",
    z = "\u017e\u017a\u017c\u017d\u0179\u017b"
  )
  from <- unlist(lapply(map, utf8ToInt), use.names = FALSE)
  to <- utf8ToInt(paste(rep(names(map), nchar(map)), collapse = ""))
  vapply(as.character(x), function(s) {
    if (is.na(s)) return(NA_character_)
    cp <- utf8ToInt(s)
    if (anyNA(cp)) return(tolower(s))
    # Lower case by code point: tolower() mangles accented letters in a C locale.
    asc <- cp >= 65 & cp <= 90
    cp[asc] <- cp[asc] + 32
    hit <- match(cp, from)
    cp[!is.na(hit)] <- to[hit[!is.na(hit)]]
    out <- intToUtf8(cp)
    out <- gsub(intToUtf8(223), "ss", out, fixed = TRUE)
    gsub(intToUtf8(230), "ae", out, fixed = TRUE)
  }, character(1), USE.NAMES = FALSE)
}

# ESPN athlete id -> name, sweater number and club, from the two rosters.
espn_roster_index <- function(sides) {
  rows <- list()
  for (s in sides) {
    r <- tryCatch(fetch_json(paste0(api_base("espn_site"), "/teams/", s$id, "/roster")), error = function(e) NULL)
    for (g in r$athletes %||% list()) for (a in g$items %||% list()) {
      rows[[length(rows) + 1]] <- list(id = as.character(a$id), name = a$fullName %||% NA_character_,
                                       number = suppressWarnings(as.integer(a$jersey %||% NA)), team = s$abbrev)
    }
  }
  if (!length(rows)) return(list(id = character(), name = character(), number = integer(), team = character()))
  list(id = vapply(rows, `[[`, "", "id"), name = vapply(rows, `[[`, "", "name"),
       number = vapply(rows, function(r) r$number, integer(1)), team = vapply(rows, `[[`, "", "team"))
}

# NHL ids for ESPN's players: club, number and surname first (so two players
# of one name on a club, like Vancouver's Elias Petterssons, stay apart),
# then club and name.
espn_to_nhl <- function(p, sides) {
  norm <- function(x) gsub("[^a-z]", "", tolower(fold_accents(x)))
  last <- function(x) norm(sub(".*\\s", "", trimws(x)))
  roster <- vctrs::vec_rbind(!!!lapply(sides, function(s) tryCatch(nhl_roster(s$abbrev), error = function(e) NULL)))
  if (is.null(roster) || !nrow(roster)) return(rep(NA_integer_, nrow(p)))
  by_num <- paste(roster$team, roster$sweater_number, last(roster$last_name))
  by_name <- paste(roster$team, norm(roster$full_name))
  id <- roster$id[match(paste(p$team, p$sweater_number, last(p$player_name)), by_num)]
  miss <- is.na(id)
  id[miss] <- roster$id[match(paste(p$team, norm(p$player_name)), by_name)][miss]
  as.integer(id)
}
