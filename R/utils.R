#' Season and game type helpers
#'
#' `nhl_season()` turns the ways people write a season into the NHL's
#' eight-digit id: `2025`, `"2025-26"` and `20252026` are all `20252026`.
#' With no argument it is the current season (a new one starts in August).
#'
#' @param season A season as a start year, `"2025-26"` or `20252026`, or
#'   `NULL` for the current one.
#' @param date Date the current season is worked out from.
#' @return The season id, a number like `20252026`.
#' @export
#' @examples
#' nhl_season("2023-24")
#' nhl_season(2024)
#' nhl_season(as.Date("2026-01-15") |> format("%Y") |> as.numeric() - 1)
nhl_season <- function(season = NULL, date = Sys.Date()) {
  if (is.null(season)) {
    d <- as.POSIXlt(date)
    y <- d$year + 1900 - (d$mon < 7)
    return(as.numeric(sprintf("%d%d", y, y + 1)))
  }
  s <- gsub("[^0-9]", "", as.character(season))
  if (nchar(s) == 8) return(as.numeric(s))
  if (nchar(s) == 4) return(as.numeric(sprintf("%s%d", s, as.numeric(s) + 1)))
  if (nchar(s) == 6) {
    y <- as.numeric(substr(s, 1, 4))
    return(as.numeric(sprintf("%d%d", y, y + 1)))
  }
  cli::cli_abort("Can't read {.val {season}} as a season; try {.val 2025-26} or {.val 20252026}.")
}

#' @rdname nhl_season
#' @param game_type `"regular"`, `"playoffs"` or `"preseason"`, or the NHL's
#'   code for one (2, 3, 1).
#' @return For `nhl_game_type()`, the code: 1, 2 or 3.
#' @export
#' @examples
#' nhl_game_type("playoffs")
nhl_game_type <- function(game_type = "regular") {
  if (is.numeric(game_type) && game_type %in% 1:3) return(as.integer(game_type))
  key <- tolower(as.character(game_type))
  code <- c(preseason = 1L, pre = 1L, regular = 2L, `regular season` = 2L, playoffs = 3L, playoff = 3L, post = 3L)[key]
  if (is.na(code)) cli::cli_abort("{.arg game_type} must be {.val regular}, {.val playoffs} or {.val preseason}.")
  unname(code)
}

season_of_game <- function(game_id) {
  y <- as.numeric(substr(as.character(game_id), 1, 4))
  as.numeric(sprintf("%d%d", y, y + 1))
}

check_game_id <- function(game_id) {
  if (length(game_id) != 1 || !grepl("^\\d{10}$", format(game_id, scientific = FALSE))) {
    cli::cli_abort("{.arg game_id} must be one ten-digit NHL game id, like {.val 2025020534}.")
  }
  format(game_id, scientific = FALSE)
}

as_date_string <- function(date) {
  if (is.null(date) || identical(date, "now")) return("now")
  format(as.Date(date), "%Y-%m-%d")
}
