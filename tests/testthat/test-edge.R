test_that("EDGE skater, goalie and team reports tidy into tables", {
  calls <- local_nhl(c("edge/skater-detail/8478402/20252026/2" = "edge-skater-detail-8478402",
                       "edge/goalie-detail/8479361/20252026/2" = "edge-goalie-detail-8479361",
                       "edge/team-detail/22/20252026/2" = "edge-team-detail-22"))
  sk <- nhl_edge_skater(8478402, "2025-26")
  expect_equal(sk$info$player_last_name, "McDavid")
  expect_true("skating_speed_speed_max_imperial" %in% names(sk$info))
  expect_s3_class(sk$sog_details, "tbl_df")
  g <- nhl_edge_goalie(8479361, 2025)
  expect_s3_class(g$shot_location_details, "tbl_df")
  t <- nhl_edge_team("EDM", "2025-26")
  expect_equal(t$info$team_abbrev, "EDM")
  expect_match(calls$log[[3]]$url, "edge/team-detail/22/20252026/2$")
})

test_that("EDGE reports and leaderboards build the right paths", {
  calls <- local_nhl(c("edge/" = "edge-skater-speed-top-10"))
  lead <- nhl_edge_leaders("skater_speed", season = "2025-26")
  expect_equal(lead$rank, 1:10)
  nhl_edge_leaders("skater_distance", position = "D", strength = "pp", season = 2025)
  nhl_edge_skater(8478402, 2025, report = "zone_time")
  nhl_edge_goalie(8479361, 2025, game_type = "playoffs", report = "5v5")
  urls <- vapply(calls$log, `[[`, "", "url")
  expect_match(urls[[1]], "edge/skater-speed-top-10/all/max/20252026/2$")
  expect_match(urls[[2]], "edge/skater-distance-top-10/D/pp/total/20252026/2$")
  expect_match(urls[[3]], "edge/skater-zone-time/8478402/20252026/2$")
  expect_match(urls[[4]], "edge/goalie-5v5-detail/8479361/20252026/3$")
})

test_that("by the numbers has one table per standout", {
  local_nhl(c("by-the-numbers" = "edge-by-the-numbers"))
  b <- nhl_edge_by_the_numbers()
  expect_s3_class(b$info$game_date, "Date")
  expect_s3_class(b$max_skating_speed_skater, "tbl_df")
  expect_equal(nrow(b$max_skating_speed_skater), 1)
})
