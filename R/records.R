#' Draft lottery winners and odds
#'
#' `nhl_draft_lottery()` is every lottery draw since 1995: the pick it won,
#' the club whose pick moved, the club that made the pick (they differ when
#' the pick had been traded), the player taken and how far the pick moved.
#' `nhl_draft_lottery_odds()` is each club's chance going in. The NHL
#' published the odds as a table through 2021; for later years it posted an
#' image, and the function says where it is.
#'
#' @param year Draft year; `NULL` for every year.
#' @return A tibble.
#' @export
#' @examplesIf interactive()
#' nhl_draft_lottery(2026)
#' nhl_draft_lottery_odds(2016)
nhl_draft_lottery <- function(year = NULL) {
  out <- nhl_records("draft-lottery-picks", filter = if (!is.null(year)) sprintf("draftYear=%s", year),
                     include = c("player.firstName", "player.lastName", "lotteryTeam.triCode", "draftTeam.triCode"))
  if (!nrow(out)) return(out)
  out$player_name <- ifelse(is.na(out$player_first_name), NA_character_, paste(out$player_first_name, out$player_last_name))
  out <- rename_cols(out, c(sequence = "pick", lottery_team_tri_code = "lottery_team", draft_team_tri_code = "draft_team",
                            effect_on_draft_order = "effect"))
  out <- out[order(-out$draft_year, out$pick), ]
  out <- out[, setdiff(names(out), c("id", "player_first_name", "player_last_name"))]
  front(out, c("draft_year", "pick", "lottery_team", "draft_team", "player_name", "player_id", "effect"))
}

#' @rdname nhl_draft_lottery
#' @export
nhl_draft_lottery_odds <- function(year) {
  raw <- nhl_records("draft-lottery-odds", filter = sprintf("draftYear=%s", year))
  html <- if (nrow(raw)) raw$odds_content[[1]] else NA_character_
  empty <- tibble::tibble(draft_year = integer(), seed = integer(), team = character(), odds = double())
  if (is.na(html) || !grepl("<table", html, fixed = TRUE)) {
    img <- regmatches(html, regexpr('src="[^"]+"', html))
    if (length(img)) cli::cli_inform(c("The NHL posted the {year} odds as an image, not a table.",
                                       i = "{.url {gsub(' ', '%20', substring(img, 6, nchar(img) - 1))}}"))
    else cli::cli_inform("The NHL has no lottery odds for {year}.")
    return(empty)
  }
  rows <- regmatches(html, gregexpr("(?s)<tr[^>]*>.*?</tr>", html, perl = TRUE))[[1]]
  cells <- lapply(rows, function(r) html_text(regmatches(r, gregexpr("(?s)<t[hd][^>]*>.*?</t[hd]>", r, perl = TRUE))[[1]]))
  cells <- Filter(function(x) length(x) >= 2 && grepl("%", x[length(x)], fixed = TRUE), cells)
  if (!length(cells)) return(empty)
  seeded <- vapply(cells, length, integer(1)) >= 3
  tibble::tibble(
    draft_year = as.integer(year),
    seed = ifelse(seeded, suppressWarnings(as.integer(vapply(cells, `[[`, "", 1))), NA_integer_),
    team = vapply(cells, function(x) x[length(x) - 1], ""),
    odds = as.numeric(sub("%", "", vapply(cells, function(x) x[length(x)], ""), fixed = TRUE)) / 100
  )
}

#' Franchise records in particular games
#'
#' Each franchise's all-time record in one kind of game, from
#' records.nhl.com: Game 7s, overtime, season openers (home, road and both),
#' outdoor games, games outside North America and other neutral sites. The
#' neutral-site tables list the venues too.
#'
#' @param type `"game7"`, `"overtime"`, `"season_opener"`, `"outdoor"`,
#'   `"outside_na"` or `"neutral_site"`.
#' @param game_type 2 (regular season) or 3 (playoffs), for `"overtime"`
#'   and `"neutral_site"`; Game 7s are always playoff games, and the outdoor,
#'   overseas and season-opener tables are regular season.
#' @return A tibble, one row per franchise (per venue for `"season_opener"`).
#' @export
#' @examplesIf interactive()
#' nhl_franchise_records("game7")
#' nhl_franchise_records("overtime", game_type = 3)
#' nhl_franchise_records("outdoor")
nhl_franchise_records <- function(type = c("game7", "overtime", "season_opener", "outdoor", "outside_na", "neutral_site"),
                                  game_type = 2) {
  type <- match.arg(type)
  game_type <- nhl_game_type(game_type)
  out <- switch(type,
    game7 = nhl_records("franchise-all-time-game-7-record"),
    overtime = nhl_records("franchise-all-time-overtime-record", filter = sprintf("gameTypeId=%s", game_type)),
    season_opener = nhl_records("franchise-season-opener-standings"),
    outdoor = nhl_records("neutral-site-standings", filter = "outdoor=true"),
    outside_na = nhl_records("neutral-site-standings", filter = "outsideNa=true"),
    neutral_site = nhl_records("neutral-site-standings", filter = sprintf("otherNeutralSite=true and gameTypeId=%s", game_type))
  )
  if (!nrow(out)) return(out)
  if (type == "season_opener") {
    fr <- nhl_franchises()
    out$franchise_name <- fr$full_name[match(out$franchise_id, fr$id)]
    out$venue <- unname(c(H = "home", R = "road", O = "all")[out$home_road])
    out$home_road <- NULL
  }
  out <- out[, setdiff(names(out), c("id", "outdoor", "outside_na", "other_neutral_site"))]
  out <- out[order(-out$games_played, out$franchise_name), ]
  front(out, c("franchise_id", "franchise_name", "venue", "game_type_id", "games_played", "wins", "losses"))
}

#' Milestones in sight
#'
#' The NHL's milestone tracker: players closing in on a round number of
#' games, goals, assists or points (skaters) or games, wins, shutouts or
#' minutes (goalies), in the regular season or the playoffs, with how many
#' they have and how many they still need. A player who has just reached one
#' stays on the list for a while; his `to_go` is zero or less and he sorts
#' after the milestones still to come.
#'
#' @param type `"skater"` or `"goalie"`.
#' @return A tibble, the nearest milestones first.
#' @export
#' @examplesIf interactive()
#' nhl_milestones()
#' nhl_milestones("goalie")
nhl_milestones <- function(type = c("skater", "goalie")) {
  type <- match.arg(type)
  out <- records_to_tibble(fetch_json(api_url("stats", "milestones", paste0(type, "s")))$data)
  if (!nrow(out)) return(out)
  col <- c("Games Played" = "games_played", Goals = "goals", Assists = "assists", Points = "points",
           Wins = "wins", Shutouts = "so", "Minutes Played" = "toi_minutes")[out$milestone]
  out$current <- vapply(seq_len(nrow(out)), function(i) {
    if (is.na(col[[i]]) || !col[[i]] %in% names(out)) NA_real_ else as.numeric(out[[col[[i]]]][[i]])
  }, numeric(1))
  out$to_go <- out$milestone_amount - out$current
  out$game_type <- ifelse(out$game_type_id == 3, "playoffs", "regular")
  out <- rename_cols(out, c(player_full_name = "player_name", team_abbrev = "team"))
  out <- out[order(out$to_go <= 0, out$to_go, out$player_name), ]
  out <- out[, setdiff(names(out), c("id", "game_type_id", "first_name", "last_name", "team_common_name", "team_place_name", "team_full_name"))]
  front(out, c("player_name", "player_id", "team", "game_type", "milestone", "milestone_amount", "current", "to_go"))
}

#' What is in the records API
#'
#' A guide to records.nhl.com: every table [nhl_records()] can fetch, with a
#' line on what it holds and the bluelineR function that wraps it, if one
#' does. Every resource was checked against the live API.
#'
#' @param pattern Optional regular expression; keeps the rows whose resource
#'   or description matches (case-insensitive).
#' @return A tibble with `resource`, `about` and `helper`.
#' @export
#' @examples
#' nhl_records_catalog()
#' nhl_records_catalog("all-star")
nhl_records_catalog <- function(pattern = NULL) {
  out <- records_catalog
  if (!is.null(pattern)) out <- out[grepl(pattern, out$resource, ignore.case = TRUE) | grepl(pattern, out$about, ignore.case = TRUE), ]
  out
}

records_catalog <- tibble::tribble(
  ~resource, ~about, ~helper,
  "all-star-coach-career-stats", "Every All-Star Game coach's record", NA,
  "all-star-goaltender-career-stats", "All-Star Game goalies, career totals", NA,
  "all-star-goaltender-game-stats", "All-Star Game goalies, game by game", NA,
  "all-star-goaltender-period-stats", "All-Star Game goalies, period by period", NA,
  "all-star-skater-career-stats", "All-Star Game skaters, career totals", NA,
  "all-star-skater-game-stats", "All-Star Game skaters, game by game", NA,
  "all-star-skater-period-stats", "All-Star Game skaters, period by period", NA,
  "all-star-team-game-stats", "All-Star Game team results", NA,
  "all-star-team-period-stats", "All-Star Game team results by period", NA,
  "all_star_team_position_leaders", "Most first- and second-team NHL All-Star selections, by position", NA,
  "all-time-record-vs-franchise", "Each franchise's all-time record against every other, home and road", NA,
  "attendance", "League attendance by season, regular season and playoffs", NA,
  "award-details", "Every award winner, with a summary of the season", NA,
  "coach", "Coach biographies", "nhl_coaches(\"bio\")",
  "coach-career-records", "Coaches' career records, regular season and playoffs", "nhl_coaches()",
  "coach-franchise-records", "Coaches' records with each franchise", "nhl_coaches(\"team\")",
  "combine", "Scouting Combine results by event", NA,
  "component-season", "Which season each part of the records site covers", NA,
  "draft", "Every draft pick since 1963", "nhl_records(\"draft\")",
  "draft-lottery-odds", "Each year's lottery format and odds (tables through 2021)", "nhl_draft_lottery_odds()",
  "draft-lottery-odds-all-time", "Notes on how the lottery odds changed over the years", NA,
  "draft-lottery-picks", "Every lottery draw since 1995", "nhl_draft_lottery()",
  "draft-prospect", "Central Scouting's prospect database", NA,
  "expansion-draft-picks", "Expansion draft selections", NA,
  "expansion-draft-rules", "Expansion draft rules by year", NA,
  "franchise", "The franchises, with first and last seasons", NA,
  "franchise-all-time-game-7-record", "Each franchise's Game 7 record", "nhl_franchise_records(\"game7\")",
  "franchise-all-time-overtime-record", "Each franchise's overtime record", "nhl_franchise_records(\"overtime\")",
  "franchise-detail", "Franchise pages: captains, coaches, GMs and retired numbers", NA,
  "franchise-season-opener-standings", "Each franchise's record in season openers", "nhl_franchise_records(\"season_opener\")",
  "franchise-season-results", "Every franchise's every season: record, finish and playoff result", NA,
  "franchise-team-totals", "Franchise all-time totals, by team name", NA,
  "game-winning-goals-stanley-cup", "The Cup-winning goal of every Final", NA,
  "general-manager", "General manager biographies", "nhl_general_managers(\"bio\")",
  "general-manager-career-records", "GMs' career records", "nhl_general_managers()",
  "general-manager-franchise-records", "GMs' records with each franchise", "nhl_general_managers(\"team\")",
  "goalie-career-stats", "Goalies' career totals by franchise and game type", NA,
  "goalie-outdoor-totals-career", "Goalies in outdoor games, career totals", NA,
  "goalie-season-stats", "Goalies' season totals since 1917", NA,
  "hof/office", "The Hockey Hall of Fame itself", NA,
  "hof/players", "Hall of Fame inductees", NA,
  "international-goaltender-career-record", "NHL best-on-best tournaments: goalie careers", "nhl_international_careers(\"goalie\")",
  "international-goaltender-tournament-record", "NHL best-on-best tournaments: goalies by tournament", "nhl_international(\"goalie\")",
  "international-playoff-series-details", "NHL best-on-best tournaments: every game", "nhl_international_games()",
  "international-skater-career-record", "NHL best-on-best tournaments: skater careers", "nhl_international_careers()",
  "international-skater-tournament-record", "NHL best-on-best tournaments: skaters by tournament", "nhl_international()",
  "international-team-tournament-record", "NHL best-on-best tournaments: teams", "nhl_international(\"team\")",
  "international-tournament-winner", "NHL best-on-best tournaments: the finals", "nhl_international_winners()",
  "media-three-star", "The media's three stars of the week and month", NA,
  "milestone-tracker", "The records site's featured milestone (one row; see nhl_milestones())", NA,
  "neutral-site-standings", "Franchise records outdoors, overseas and at other neutral sites", "nhl_franchise_records(\"outdoor\")",
  "officials", "Every NHL referee and linesman", "nhl_records(\"officials\")",
  "olympic-goaltender-career-record", "Olympic goalies, career", "nhl_international_careers(\"goalie\", olympics = TRUE)",
  "olympic-skater-career-record", "Olympic skaters, career", "nhl_international_careers(olympics = TRUE)",
  "olympic-tournament-winner", "Olympic medalists with NHL players", "nhl_olympic_podiums()",
  "phwa-all-star-team", "The writers' All-Star teams by season", NA,
  "player", "Player register: every NHL player's vitals", NA,
  "playoff-captains", "Captains of every playoff team", NA,
  "playoff-franchise-vs-team", "Each franchise's playoff series record against every opponent", "nhl_playoff_series()",
  "playoff-round-robin-game", "The 2020 qualifying round-robin games", NA,
  "playoff-series", "Every playoff game with its series state", NA,
  "playoff-team-series-stats-both-teams", "Team totals for every playoff series", NA,
  "record-category", "The records site's categories", NA,
  "record-video-detail", "Videos attached to records", NA,
  "scf-team-totals", "Each franchise's Stanley Cup Final record", NA,
  "season/event", "Special events: outdoor games, Global Series, All-Star weekends", NA,
  "season/event/games", "Games at special events", NA,
  "season/event/offseason-games-outside-north-america", "Exhibition games outside North America", NA,
  "season/event/preseason-games-outside-north-america", "Preseason games outside North America", NA,
  "skater-career-scoring-regular-season", "Skaters' career regular-season scoring by franchise", NA,
  "skater-outdoor-totals-career", "Skaters in outdoor games, career totals", NA,
  "skater-playoff-scoring", "Skaters' playoff scoring, with Game 7s and multi-goal games", NA,
  "skater-real-time-stats-season", "Skaters' hits, blocks, giveaways and faceoffs by season", NA,
  "team", "Every team name, with arena and colours", NA,
  "team-affiliate", "Each franchise's AHL and ECHL affiliates", NA,
  "trophy", "The NHL's trophies and what they are for", NA,
  "venue", "Every venue the NHL has played in", NA,
  "yearly-playoff-series-details", "Every playoff game since 1918, with coaches and stars", "nhl_playoff_games()"
)

# Text of HTML fragments: tags dropped, the common entities decoded, space
# squeezed. All byte-wise and marked UTF-8 at the end, so a C locale cannot
# translate the accents into "<U+00E9>" on the way through.
html_text <- function(x) {
  x <- enc2utf8(x)
  x <- gsub("<[^>]+>", "", x, useBytes = TRUE)
  named <- c("&nbsp;" = " ", "&amp;" = "&", "&rsquo;" = "\u2019", "&lsquo;" = "\u2018", "&ndash;" = "\u2013",
             "&mdash;" = "\u2014", "&eacute;" = "\u00e9", "&quot;" = "\"", "&lt;" = "<", "&gt;" = ">")
  for (e in names(named)) x <- gsub(e, enc2utf8(named[[e]]), x, fixed = TRUE, useBytes = TRUE)
  x <- vapply(x, function(s) {
    for (cd in unique(regmatches(s, gregexpr("&#[0-9]+;", s, useBytes = TRUE))[[1]])) {
      s <- gsub(cd, intToUtf8(as.integer(gsub("[^0-9]", "", cd))), s, fixed = TRUE, useBytes = TRUE)
    }
    s
  }, "", USE.NAMES = FALSE)
  x <- trimws(gsub("[[:space:]]+", " ", x, useBytes = TRUE))
  Encoding(x) <- "UTF-8"
  x
}
