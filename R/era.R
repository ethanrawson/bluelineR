#' Each season's scoring environment
#'
#' Every completed NHL regular season since 1917-18: the games each club
#' played, goals and assists per team-game, skaters dressed per team-game and
#' the league save percentage (from 1955-56, when the NHL started counting
#' shots against). [nhl_era_adjust()] rescales players' seasons by it.
#'
#' The table ships with the package, so it works offline; `refresh = TRUE`
#' rebuilds it from the stats API (three requests a season, so a minute or
#' two), for a season completed since this version.
#'
#' @param refresh Rebuild from the API instead of using the shipped table.
#' @return A tibble, one row per season.
#' @export
#' @examples
#' env <- nhl_league_env()
#' env[env$season %in% c(19551956, 19811982, 20252026), ]
nhl_league_env <- function(refresh = FALSE) {
  if (!refresh) return(league_env_data)
  seasons <- setdiff(1917:(as.numeric(substr(nhl_season(), 1, 4)) - 1), 2004)
  rows <- lapply(seasons, function(y) {
    id <- y * 10001 + 1
    teams <- nhl_stats("team/summary", id)
    skaters <- nhl_stats("skater/summary", id)
    goalies <- nhl_stats("goalie/summary", id)
    games <- sum(teams$games_played)
    shots <- if ("shots_against" %in% names(goalies)) goalies$shots_against else NA
    has_shots <- !is.na(shots) & shots > 0
    tibble::tibble(
      season = id, schedule = max(teams$games_played),
      goals_per_game = sum(teams$goals_for) / games,
      assists_per_game = sum(skaters$assists, na.rm = TRUE) / games,
      skaters_per_game = sum(skaters$games_played, na.rm = TRUE) / games,
      save_pct = if (any(has_shots)) 1 - sum(goalies$goals_against[has_shots]) / sum(shots[has_shots]) else NA_real_
    )
  })
  vctrs::vec_rbind(!!!rows)
}

#' Era-adjusted stats
#'
#' Rescales each season to one scoring environment, by default the average
#' of the last ten completed seasons over an 82-game schedule, so a 1952
#' season and a 2022 one read on the same scale:
#'
#' * goals by the league's goals a game, assists by its assists a game, both
#'   by the schedule (to 82 games) and by roster size (skaters dressed a game:
#'   a 1920s star shared the scoring with nine or ten teammates, not
#'   seventeen), as Hockey-Reference adjusts;
#' * a goalie's goals-against average by the league's goals a game, and his
#'   save percentage against the league's that season.
#'
#' Works on any table of player seasons with a season column (`season_id`
#' from [nhl_stats()], `season` from [nhl_player()]'s `season_totals`). Only
#' NHL regular seasons are adjusted; other leagues, the playoffs and any
#' season [nhl_league_env()] does not cover (the one in progress) get `NA`.
#'
#' @param stats Player seasons: `goals` and `assists` for skaters,
#'   `goals_against_average` (or `goals_against_avg`) and `save_pct` (or
#'   `save_pctg`) for goalies.
#' @param baseline The seasons, as start years, whose average is the
#'   standard; the default is the last ten in [nhl_league_env()].
#' @param env The environment table; [nhl_league_env()] by default.
#' @return `stats` with `adj_goals`, `adj_assists` and `adj_points` (skater
#'   columns present) and `adj_gaa` and `save_pct_vs_league` (goalie columns
#'   present).
#' @export
#' @examples
#' gretzky <- data.frame(season_id = c(19811982, 19851986), goals = c(92, 52), assists = c(120, 163))
#' nhl_era_adjust(gretzky)
nhl_era_adjust <- function(stats, baseline = NULL, env = nhl_league_env()) {
  season_col <- intersect(c("season_id", "season"), names(stats))[1]
  if (is.na(season_col)) cli::cli_abort("{.arg stats} needs a {.field season_id} or {.field season} column.")
  start <- env$season %/% 10000
  if (is.null(baseline)) baseline <- sort(start, decreasing = TRUE)[seq_len(min(10, length(start)))]
  base <- env[start %in% baseline, ]
  if (!nrow(base)) cli::cli_abort("None of the {.arg baseline} seasons are in {.arg env}.")
  b_gpg <- mean(base$goals_per_game); b_apg <- mean(base$assists_per_game); b_spg <- mean(base$skaters_per_game)

  season <- as.numeric(stats[[season_col]])
  e <- env[match(season, env$season), ]
  ok <- !is.na(e$season)
  if ("league_abbrev" %in% names(stats)) ok <- ok & stats$league_abbrev %in% "NHL"
  if ("game_type_id" %in% names(stats)) ok <- ok & stats$game_type_id %in% 2
  if (any(!ok & !is.na(season))) {
    missing <- unique(season[!ok & !is.na(season) & is.na(e$season)])
    if (length(missing)) cli::cli_inform("No scoring environment for {season_label(missing)}; those rows are {.val NA}. See {.fn nhl_league_env}.")
  }
  per <- 82 / e$schedule * e$skaters_per_game / b_spg
  out <- stats
  if (all(c("goals", "assists") %in% names(stats))) {
    out$adj_goals <- ifelse(ok, stats$goals * b_gpg / e$goals_per_game * per, NA_real_)
    out$adj_assists <- ifelse(ok, stats$assists * b_apg / e$assists_per_game * per, NA_real_)
    out$adj_points <- out$adj_goals + out$adj_assists
  }
  gaa <- intersect(c("goals_against_average", "goals_against_avg"), names(stats))[1]
  if (!is.na(gaa)) out$adj_gaa <- ifelse(ok, stats[[gaa]] * b_gpg / e$goals_per_game, NA_real_)
  sv <- intersect(c("save_pct", "save_pctg"), names(stats))[1]
  if (!is.na(sv)) out$save_pct_vs_league <- ifelse(ok, stats[[sv]] - e$save_pct, NA_real_)
  out
}
