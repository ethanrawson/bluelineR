local_ppt <- function(env = parent.frame()) {
  local_nhl(c("live.nhle.com/ppt/20232024/2023020500/EntityRegistration.json" = "ppt-2023020500-EntityRegistration",
              "live.nhle.com/ppt/20232024/2023020500/LiveEventSummary.json" = "ppt-2023020500-LiveEventSummary",
              "live.nhle.com/ppt/20232024/2023020500/PlayerStats.json" = "ppt-2023020500-PlayerStats"), env)
}

test_that("entities map tracking ids to NHL players and clubs", {
  local_ppt()
  e <- nhl_tracking_entities(2023020500)
  expect_setequal(unique(e$entity_type), c("Player", "Official", "Zamboni", "BallOrPuck"))
  barkov <- e[e$name %in% "Aleksander Barkov", ]
  expect_equal(barkov$player_id, 8477493)
  expect_equal(barkov$team, "FLA")
  expect_true(all(is.na(e$team[e$entity_type != "Player"])))
})

test_that("the summary has players, clubs' possession and the puck", {
  local_ppt()
  tr <- nhl_tracking_summary(2023020500)
  expect_named(tr, c("players", "teams", "puck", "info"))
  expect_equal(nrow(tr$players), 40)
  expect_setequal(tr$teams$team, c("FLA", "STL"))
  expect_equal(sum(tr$teams$possession_pct), 100, tolerance = 0.01)
  reinhart <- tr$players[tr$players$name %in% "Sam Reinhart", ]
  expect_equal(round(reinhart$speed_max_mph, 1), 20.7)
  expect_equal(round(reinhart$distance_miles, 2), 2.99)
  expect_true(all(c("possession_time", "possession_time_o_zone", "zone_offense_starts") %in% names(tr$players)))
  expect_equal(round(tr$puck$speed_max_mph, 1), 94.8)
  expect_equal(tr$info$home_direction_of_play, "RightToLeft")
})

test_that("player stats carry ice time by strength and the shift list", {
  local_ppt()
  ps <- nhl_tracking_player_stats(2023020500)
  expect_equal(nrow(ps), 40)
  b <- ps[ps$player_id == 8477493, ]
  expect_equal(c(b$toi_total, b$toi_5v5, b$faceoffs_won), c(968, 841, 13))
  expect_equal(b$name, "Aleksander Barkov")
  expect_s3_class(b$shift_list[[1]], "tbl_df")
})

test_that("missing summaries say which seasons have them", {
  local_mocked_bindings(fetch_json = function(url, ...) {
    cli::cli_abort("nope", class = "bluelineR_not_found")
  })
  expect_error(nhl_tracking_summary(2025020534), class = "bluelineR_no_tracking")
})
