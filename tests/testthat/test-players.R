test_that("nhl_player splits the page into tables", {
  local_nhl(c("player/8478402/landing" = "player-8478402"))
  p <- nhl_player(8478402)
  expect_named(p, c("bio", "season_totals", "last_5_games", "awards", "career_totals"))
  expect_equal(nrow(p$bio), 1)
  expect_equal(p$bio$last_name, "McDavid")
  expect_gt(nrow(p$season_totals), 5)
})

test_that("game logs from before ice time was recorded still read", {
  local_nhl(c("game-log" = "game-log-8447400-19811982-2"))
  log <- nhl_player_game_log(8447400, "1981-82")
  expect_equal(nrow(log), 5)
  expect_true(all(is.na(log$toi_seconds)))
  expect_true(all(c("goals", "assists", "shots", "plus_minus") %in% names(log)))
})

test_that("game logs, search, rosters and club stats", {
  local_nhl(c("game-log" = "game-log-8478402-20252026-2", "search/player" = "search-mcdavid",
              "roster/EDM" = "roster-EDM-20252026", "club-stats/EDM" = "club-stats-EDM-20252026-2"))
  log <- nhl_player_game_log(8478402, "2025-26")
  expect_equal(nrow(log), 82)
  expect_s3_class(log$game_date, "Date")
  s <- nhl_player_search("mcdavid")
  expect_true(8478402 %in% s$player_id)
  r <- nhl_roster("EDM", "2025-26")
  expect_setequal(unique(r$position_group), c("F", "D", "G"))
  expect_true("Connor McDavid" %in% r$full_name)
  cs <- nhl_team_stats("EDM", "2025-26")
  expect_named(cs, c("skaters", "goalies"))
})

test_that("image URLs", {
  expect_equal(nhl_headshot_url(8478402), "https://assets.nhle.com/mugs/nhl/latest/8478402.png")
  expect_equal(nhl_headshot_url(8478402, "EDM", "2016-17"), "https://assets.nhle.com/mugs/nhl/20162017/EDM/8478402.png")
  expect_equal(nhl_logo_url("edm", "dark"), "https://assets.nhle.com/logos/nhl/svg/EDM_dark.svg")
  expect_error(nhl_headshot_url(8478402, season = 2016), "team")
})
