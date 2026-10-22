#' Goal tracking frames
#'
#' The NHL replays every goal from puck and player tracking: about 14
#' seconds of every skater, both goalies and the puck, ten frames a second,
#' for every goal from 2023-24 on. `nhl_goal_tracking()` returns those
#' frames, one row per object per frame, with positions in feet from centre
#' ice in the play-by-play's orientation (x along the rink, y across it).
#'
#' The files live on `wsr.nhle.com` and answer only requests that come from
#' nhl.com, so the request says it does (a `Referer` header).
#' `nhl_goal_replay()` is the goal itself as the NHL's replay page has it:
#' scorer, assists, strength, the score, both clubs' logos and the highlight
#' video.
#'
#' @param game_id Ten-digit NHL game id.
#' @param event_id The goal's event id in the play-by-play (`event_id` in
#'   [nhl_pbp()]).
#' @return `nhl_goal_tracking()`: a tibble with columns `frame`, `time`
#'   (seconds from the first frame), `entity_id`, `is_puck`, `player_id`,
#'   `sweater_number`, `team`, `x`, `y`. The goal's game and event ids ride
#'   along as attributes. `nhl_goal_replay()`: a one-row tibble.
#' @export
#' @examplesIf interactive()
#' frames <- nhl_goal_tracking(2025020534, 777)
#' plot_goal(frames)
#' nhl_goal_replay(2025020534, 777)
nhl_goal_tracking <- function(game_id, event_id) {
  game_id <- check_game_id(game_id)
  url <- api_url("tracking", season_of_game(game_id), game_id, paste0("ev", event_id, ".json"))
  raw <- tryCatch(
    fetch_json(url, headers = list(Referer = "https://www.nhl.com/")),
    bluelineR_http_error = function(e) cli::cli_abort(
      c("The NHL has no tracking for this goal.", i = "Goal tracking starts with 2023-24, and a live game's lands a few minutes after the goal."),
      parent = e, class = "bluelineR_no_tracking"),
    bluelineR_not_found = function(e) cli::cli_abort(
      c("The NHL has no tracking for this goal.", i = "Goal tracking starts with 2023-24, and a live game's lands a few minutes after the goal."),
      parent = e, class = "bluelineR_no_tracking")
  )
  parse_tracking(raw, game_id, event_id)
}

#' @rdname nhl_goal_tracking
#' @export
nhl_goal_replay <- function(game_id, event_id) {
  raw <- fetch_json(api_url("web", "ppt-replay", "goal", check_game_id(game_id), event_id))
  g <- raw$goal
  if (is.null(g)) cli::cli_abort("No goal {event_id} in game {game_id}.")
  goal <- records_to_tibble(list(g))
  goal$assists <- list(records_to_tibble(g$assists %||% list()))
  goal$game_id <- raw$id
  goal$event_id <- as.numeric(event_id)
  goal$game_date <- as.Date(raw$gameDate)
  goal$away_team <- raw$awayTeam$abbrev
  goal$home_team <- raw$homeTeam$abbrev
  goal$away_logo <- raw$awayTeam$logo %||% NA_character_
  goal$home_logo <- raw$homeTeam$logo %||% NA_character_
  goal$away_logo_dark <- raw$awayTeam$darkLogo %||% NA_character_
  goal$home_logo_dark <- raw$homeTeam$darkLogo %||% NA_character_
  names(goal)[names(goal) == "period_descriptor_number"] <- "period"
  names(goal)[names(goal) == "period_descriptor_period_type"] <- "period_type"
  front(goal, c("game_id", "event_id", "game_date", "away_team", "home_team", "period", "period_type",
                "time_in_period", "strength", "team_abbrev", "player_id", "first_name", "last_name",
                "shot_type", "away_score", "home_score", "assists", "ppt_replay_url", "highlight_clip_sharing_url"))
}

#' Read tracking frames from a file
#'
#' Parses a tracking file saved from `wsr.nhle.com` (the JSON
#' [nhl_goal_tracking()] downloads) into the same tibble. The package ships
#' one, Connor McDavid's shorthanded breakaway goal at Boston on 18 December
#' 2025: `system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")`.
#'
#' @param path Path to the JSON file (gzipped or not).
#' @param game_id,event_id Kept as attributes, as [nhl_goal_tracking()] does.
#' @return A tibble of frames; see [nhl_goal_tracking()].
#' @export
#' @examples
#' path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
#' frames <- read_goal_tracking(path, 2025020534, 777)
#' head(frames)
read_goal_tracking <- function(path, game_id = NA, event_id = NA) {
  con <- if (grepl("\\.gz$", path)) gzfile(path, "rt") else file(path, "rt")
  on.exit(close(con))
  raw <- jsonlite::fromJSON(paste(readLines(con, warn = FALSE), collapse = ""), simplifyVector = FALSE)
  parse_tracking(raw, game_id, event_id)
}

parse_tracking <- function(raw, game_id = NA, event_id = NA) {
  if (!length(raw)) cli::cli_abort("The tracking file has no frames.")
  t0 <- as.numeric(raw[[1]]$timeStamp)
  rows <- lapply(seq_along(raw), function(i) {
    f <- raw[[i]]
    objs <- Filter(function(o) is.numeric(o$x) && is.numeric(o$y), f$onIce)
    if (!length(objs)) return(NULL)
    # By entity id, the order the NHL's own replay (and the classifier) walk them in.
    objs <- objs[order(vapply(objs, function(o) as.numeric(o$id %||% NA), numeric(1)))]
    num <- function(v) if (is.null(v) || identical(v, "")) NA_real_ else as.numeric(v)
    chr <- function(v) if (is.null(v) || identical(v, "")) NA_character_ else as.character(v)
    objs <- unname(objs)
    tibble::tibble(
      frame = i,
      time = (as.numeric(f$timeStamp) - t0) / 10,
      entity_id = vapply(objs, function(o) num(o$id), numeric(1)),
      player_id = vapply(objs, function(o) num(o$playerId), numeric(1)),
      sweater_number = vapply(objs, function(o) num(o$sweaterNumber), numeric(1)),
      team = vapply(objs, function(o) chr(o$teamAbbrev), character(1)),
      x = vapply(objs, function(o) o$x, numeric(1)) / 12 - 100,
      y = 42.5 - vapply(objs, function(o) o$y, numeric(1)) / 12
    )
  })
  out <- tibble::as_tibble(vctrs::vec_rbind(!!!Filter(Negate(is.null), rows)))
  out$is_puck <- out$entity_id == 1
  out <- front(out, c("frame", "time", "entity_id", "is_puck", "player_id", "sweater_number", "team", "x", "y"))
  attr(out, "game_id") <- if (is.na(game_id)) NA else as.numeric(game_id)
  attr(out, "event_id") <- if (is.na(event_id)) NA else as.numeric(event_id)
  out
}

#' When the puck went in
#'
#' The frame a goal was scored on: the first time the puck is over the goal
#' line, between the posts and no deeper than the net, for two frames
#' running, at the net it finishes the clip in. (The first frame in any net
#' is wrong on about one goal in five: a clip can open with the puck at the
#' other net, or blip over the line before the real goal.)
#'
#' @param frames Tracking frames from [nhl_goal_tracking()].
#' @return The frame number, or `NA` if the puck never goes in.
#' @export
#' @examples
#' path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
#' goal_frame(read_goal_tracking(path))
goal_frame <- function(frames) {
  puck <- frames[frames$is_puck, c("frame", "x", "y")]
  puck <- puck[order(puck$frame), ]
  if (!nrow(puck)) return(NA_integer_)
  tail_x <- utils::tail(puck$x, 20)
  side <- sign(sum(tail_x))
  in_net <- abs(puck$x) >= 89 & abs(puck$x) <= 92.6 & abs(puck$y) <= 3.2
  at_side <- in_net & (side == 0 | sign(puck$x) == side)
  # Two frames running, by frame number (a frame can be missing the puck).
  consecutive <- at_side & c(at_side[-1], FALSE) & c(diff(puck$frame) == 1, FALSE)
  i <- which(consecutive)
  if (!length(i)) i <- which(at_side)
  if (!length(i)) i <- which(in_net)
  if (!length(i)) return(NA_integer_)
  as.integer(puck$frame[[i[[1]]]])
}

#' Skating speed from tracking
#'
#' Each skater's speed in miles per hour at every frame, over the 0.6
#' seconds around it (three frames each way), as the NHL's replays show it.
#'
#' @inheritParams goal_frame
#' @return `frames` without the puck, plus a `speed_mph` column.
#' @export
#' @examples
#' path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
#' spd <- skater_speed(read_goal_tracking(path))
#' spd[which.max(spd$speed_mph), c("frame", "player_id", "speed_mph")]
skater_speed <- function(frames) {
  sk <- frames[!frames$is_puck, ]
  sk <- sk[order(sk$entity_id, sk$frame), ]
  sk$speed_mph <- NA_real_
  for (id in unique(sk$entity_id)) {
    i <- which(sk$entity_id == id)
    n <- length(i)
    for (j in seq_len(n)) {
      a <- i[max(1, j - 3)]
      b <- i[min(n, j + 3)]
      dt <- sk$time[b] - sk$time[a]
      if (dt > 0) sk$speed_mph[i[j]] <- sqrt((sk$x[b] - sk$x[a])^2 + (sk$y[b] - sk$y[a])^2) / dt * 0.6818
    }
  }
  sk[order(sk$frame, sk$entity_id), ]
}
