test_that("nhl_scores returns a night's games with scores", {
  calls <- local_nhl(c("score/2026-10-20" = "score-2026-10-20"))
  s <- nhl_scores("2026-10-20")
  expect_equal(nrow(s), 11)
  expect_s3_class(s$game_date, "Date")
  expect_true(all(c("id", "away_team_abbrev", "away_team_score", "home_team_abbrev", "home_team_score") %in% names(s)))
  tor <- s[s$away_team_abbrev == "TOR", ]
  expect_equal(c(tor$away_team_score, tor$home_team_score), c(6, 2))
  expect_match(calls$log[[1]]$url, "api-web.nhle.com/v1/score/2026-10-20$")
})

test_that("nhl_schedule and nhl_team_schedule list games", {
  local_nhl(c("schedule/2026-10-20" = "schedule-2026-10-20", "club-schedule-season/EDM/20252026" = "club-schedule-EDM-20252026"))
  sch <- nhl_schedule("2026-10-20")
  expect_gt(nrow(sch), 0)
  expect_s3_class(sch$date, "Date")
  ts <- nhl_team_schedule("edm", "2025-26")
  expect_equal(nrow(ts), 10)
  expect_true(all(ts$away_team_abbrev == "EDM" | ts$home_team_abbrev == "EDM"))
})

test_that("nhl_standings has every club", {
  local_nhl(c("standings/2026-04-15" = "standings-2026-04-15"))
  st <- nhl_standings("2026-04-15")
  expect_equal(nrow(st), 32)
  expect_true(all(c("team_abbrev", "points", "goal_differential") %in% names(st)))
})

test_that("nhl_pbp reads players, strength, score and orientation", {
  local_nhl(c("play-by-play" = "pbp-2025020534"))
  p <- nhl_pbp(2025020534)
  goals <- p[p$type == "goal", ]
  expect_equal(nrow(goals), 4)
  shg <- goals[goals$event_id == 777, ]
  expect_equal(shg$player_1_name, "Connor McDavid")
  expect_equal(shg$strength_state, "4v5")
  expect_equal(shg$goalie_name, "Jeremy Swayman")
  expect_equal(c(shg$away_score, shg$home_score), c(3, 1))
  # Every goal is in the offensive zone once turned to attack right.
  expect_true(all(goals$x_fixed > 25))
  expect_equal(shg$game_seconds, 2 * 1200 + 101)
  expect_false(any(grepl("^details_", names(p))))
})

test_that("nhl_boxscore splits skaters, goalies and teams", {
  local_nhl(c("boxscore" = "boxscore-2025020534"))
  b <- nhl_boxscore(2025020534)
  expect_named(b, c("skaters", "goalies", "teams"))
  expect_setequal(unique(b$skaters$team), c("EDM", "BOS"))
  expect_true(all(b$goalies$position_group == "goalies"))
  expect_equal(sum(b$skaters$goals), sum(b$teams$score))
})

test_that("nhl_shifts keeps shifts and adds seconds", {
  local_nhl(c("shiftcharts" = "shifts-2025020534"))
  sh <- nhl_shifts(2025020534)
  expect_true(all(sh$type_code == 517))
  expect_true(all(sh$end_seconds - sh$start_seconds == sh$duration_seconds, na.rm = TRUE))
  expect_gt(nrow(nhl_shifts(2025020534, shifts_only = FALSE)), nrow(sh))
})

test_that("game ids are checked", {
  expect_error(nhl_pbp(123), "ten-digit")
})

test_that("boxscores from before ice time was recorded still read", {
  local_nhl(c("boxscore" = "boxscore-1981020100"))
  b <- nhl_boxscore(1981020100)
  expect_equal(nrow(b$skaters), 8)
  expect_true(all(is.na(b$skaters$toi_seconds)))
  expect_true(all(c("goals", "assists", "sog") %in% names(b$skaters)))
})

test_that("plot_shots() says why when a game has no shot locations", {
  skip_if_not_installed("ggplot2")
  old <- tibble::tibble(type = c("goal", "penalty"), x_fixed = NA_real_, y_fixed = NA_real_, event_team = "EDM")
  expect_error(plot_shots(old), "2009-10")
})
