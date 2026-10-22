#' bluelineR: Tidy Access to the NHL's Web, Stats, EDGE and Goal-Tracking APIs
#'
#' bluelineR wraps the public endpoints behind NHL.com and returns tibbles
#' with snake_case names:
#'
#' * **Games**: [nhl_scores()], [nhl_schedule()], [nhl_pbp()],
#'   [nhl_boxscore()], [nhl_shifts()], [nhl_standings()].
#' * **Goal tracking**: [nhl_goal_tracking()] returns the puck and player
#'   positions behind every goal since 2023-24, ten frames a second;
#'   [classify_goal()] reads how it was scored and [plot_goal()] draws it.
#' * **Game tracking summaries** (2021-22 to 2023-24 and some of 2020-21 and
#'   2024-25): [nhl_tracking_summary()] has each player's speed, distance,
#'   zone time and puck possession time, and each club's possession share.
#' * **NHL EDGE**: [nhl_edge_skater()], [nhl_edge_goalie()],
#'   [nhl_edge_team()], [nhl_edge_leaders()], [nhl_edge_by_the_numbers()].
#' * **Players, teams, drafts**: [nhl_player()], [nhl_player_game_log()],
#'   [nhl_player_search()], [nhl_roster()], [nhl_team_stats()],
#'   [nhl_draft_rankings()], [nhl_draft_picks()].
#' * **Stats and records APIs**: [nhl_stats()], [nhl_records()].
#' * Anything else: [nhl_api()].
#'
#' Requests are throttled and retried politely; see [bluelineR-options].
#'
#' @keywords internal
#' @importFrom rlang .data %||%
"_PACKAGE"

#' Package options
#'
#' * `bluelineR.rate`: requests per second, at most (default 5).
#' * `bluelineR.max_tries`: attempts per request, retrying rate limits
#'   (HTTP 429) and server errors with backoff (default 4).
#' * `bluelineR.cache`: keep responses in memory for the session, so asking
#'   twice costs one request (default `FALSE`). Clear it with
#'   [nhl_cache_clear()].
#' * `bluelineR.user_agent`: the User-Agent sent with each request.
#'
#' @name bluelineR-options
NULL
