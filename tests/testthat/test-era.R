test_that("nhl_league_env() ships every completed season", {
  env <- nhl_league_env()
  expect_named(env, c("season", "schedule", "goals_per_game", "assists_per_game", "skaters_per_game", "save_pct"))
  expect_equal(env$season[1], 19171918)
  expect_false(20042005 %in% env$season)
  expect_true(all(is.na(env$save_pct[env$season < 19551956])))
  expect_false(anyNA(env$save_pct[env$season >= 19551956]))
  expect_true(all(env$skaters_per_game > 5 & env$skaters_per_game < 19))
})

test_that("nhl_era_adjust() rescales by scoring, schedule and roster size", {
  env <- tibble::tibble(season = c(19501951, 20202021, 20212022), schedule = c(70, 82, 82),
                        goals_per_game = c(2, 3, 3), assists_per_game = c(3, 5, 5),
                        skaters_per_game = c(15, 18, 18), save_pct = c(NA, 0.9, 0.91))
  x <- data.frame(season_id = c(19501951, 20212022), goals = c(40, 40), assists = c(30, 30))
  out <- nhl_era_adjust(x, baseline = 2020:2021, env = env)
  # 1950-51: x 3/2 scoring, x 82/70 schedule, x 15/18 roster
  expect_equal(out$adj_goals[1], 40 * 3 / 2 * 82 / 70 * 15 / 18)
  expect_equal(out$adj_assists[1], 30 * 5 / 3 * 82 / 70 * 15 / 18)
  expect_equal(out$adj_points, out$adj_goals + out$adj_assists)
  # a baseline season stays as it is
  expect_equal(out$adj_goals[2], 40)
})

test_that("nhl_era_adjust() reads goalies against the league", {
  g <- data.frame(season_id = c(19981999, 19501951), goals_against_average = c(2, 2), save_pct = c(0.92, NA))
  out <- nhl_era_adjust(g)
  env <- nhl_league_env()
  e <- env[env$season == 19981999, ]
  expect_equal(out$save_pct_vs_league[1], 0.92 - e$save_pct)
  expect_true(out$adj_gaa[1] > 2)            # 1998-99 scored less than today
  expect_true(is.na(out$save_pct_vs_league[2]))
})

test_that("nhl_era_adjust() leaves other leagues, playoffs and unknown seasons NA", {
  p <- data.frame(season = c(19811982, 19781979, 19811982, 20262027), league_abbrev = c("NHL", "WHA", "NHL", "NHL"),
                  game_type_id = c(2, 2, 3, 2), goals = c(92, 46, 7, 3), assists = c(120, 64, 19, 4))
  expect_message(out <- nhl_era_adjust(p), "2026-27")
  expect_false(is.na(out$adj_goals[1]))
  expect_true(all(is.na(out$adj_goals[2:4])))
  expect_error(nhl_era_adjust(data.frame(goals = 1)), "season")
})
