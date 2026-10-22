test_that("nhl_player_bio() has the draft, the awards with their seasons, and the bio", {
  local_nhl(c("v2/player/8478402/bio" = "player-bio-8478402"))
  b <- nhl_player_bio(8478402)
  expect_equal(b$info$last_name, "McDavid")
  expect_equal(b$info$birth_city, "Richmond Hill")
  expect_equal(c(b$info$draft_year, b$info$draft_overall), c(2015L, 1L))
  expect_equal(b$info$drafted_from_team, "Erie")
  expect_true(nchar(b$info$bio) > 100)
  expect_true(all(c("Hart", "Art Ross", "Conn Smythe") %in% b$awards$short_name))
  expect_false(anyNA(b$awards$year_won))
  expect_equal(b$awards$year_won[b$awards$short_name == "Conn Smythe"], 2024L)
})

test_that("nhl_team_comparison() lines two clubs up stat by stat", {
  local_nhl(c("team-stats-comparison/EDM/TOR" = "team-comparison-EDM-TOR"))
  cmp <- nhl_team_comparison("EDM", "TOR", season = 2025)
  expect_true("pp_pctg" %in% cmp$stat)
  pp <- cmp[cmp$stat == "pp_pctg", ]
  expect_equal(c(pp$team_a, pp$team_b), c("EDM", "TOR"))
  expect_equal(pp$team_a_rank, 1)
})

test_that("nhl_broadcasts() lists national, regional and streaming options", {
  local_nhl(c("how-to-watch/2026020066" = "how-to-watch-2026020066"))
  b <- nhl_broadcasts(2026020066)
  expect_true(nrow(b) > 3)
  expect_true(any(b$market == "Regional Sports Network" & !is.na(b$team)))
  expect_true(any(grepl("ESPN", b$network)))
  expect_true(all(c("logo_light", "logo_dark") %in% names(b)))
  expect_true(any(grepl("^https://assets.nhle.com/.*light", b$logo_light)))
})

test_that("nhl_quick_stats() reads the static standings and leader files", {
  local_nhl(c("psr/" = "psr-standings"))
  st <- nhl_quick_stats("standings", season = 2026)
  expect_equal(nrow(st), 32)
  expect_setequal(unique(st$division), c("Atlantic", "Metropolitan", "Central", "Pacific"))
})

test_that("nhl_quick_stats() leaders carry their category", {
  local_nhl(c("psr/" = "psr-skater-leaders"))
  sk <- nhl_quick_stats("skater_leaders", season = 2026)
  expect_setequal(unique(sk$category), c("goals", "assists", "points", "shots"))
  expect_true(all(c("first_name", "last_name", "value") %in% names(sk)))
})

test_that("nhl_videos() and nhl_news() read NHL.com's content API", {
  calls <- local_nhl(c("content/en-us/videos" = "content-videos", "content/en-us/stories" = "content-stories"))
  v <- nhl_videos(tag = "teamid-22", limit = 3)
  expect_equal(nrow(v), 3)
  expect_true(all(!is.na(v$brightcove_id)))
  expect_match(calls$log[[1]]$url, "\\$limit=3&tags.slug=teamid-22", fixed = FALSE)
  n <- nhl_news(limit = 3)
  expect_true(all(startsWith(n$url, "https://www.nhl.com/news/")))
  expect_true(all(diff(as.numeric(n$date)) <= 0))
})

test_that("nhl_playoff_series() and nhl_playoff_games() read the records site", {
  calls <- local_nhl(c("playoff-franchise-vs-team" = "records-playoff-vs-team-22",
                       "yearly-playoff-series-details" = "records-playoff-games-20242025"))
  s <- nhl_playoff_series("EDM", "FLA")
  expect_true(all(s$opponent_team_name == "Florida Panthers"))
  expect_equal(calls$log[[1]]$query$cayenneExp, "teamId=22")
  g <- nhl_playoff_games(2024)
  expect_true(nrow(g) > 0)
  expect_true(all(c("series_title", "game_id", "home_score", "visiting_score") %in% names(g)))
  expect_equal(calls$log[[2]]$query$cayenneExp, "season=20242025")
})

test_that("nhl_edge_leaders() reaches the new boards", {
  calls <- local_nhl(c("team-zone-time-top-10" = "edge-team-zone-time-top-10", "goalie-5v5-top-10" = "edge-goalie-5v5-top-10"))
  z <- nhl_edge_leaders("team_zone_time", strength = "pp", season = "now")
  expect_equal(nrow(z), 10)
  expect_match(calls$log[[1]]$url, "team-zone-time-top-10/pp/offensive/now")
  g <- nhl_edge_leaders("goalie_5v5", sort_by = "save-pctg-close", season = "now")
  expect_equal(g$rank, 1:10)
  expect_match(calls$log[[2]]$url, "goalie-5v5-top-10/save-pctg-close/now")
})
