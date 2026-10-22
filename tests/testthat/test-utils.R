test_that("seasons are read in every usual form", {
  expect_equal(nhl_season(20252026), 20252026)
  expect_equal(nhl_season("2025-26"), 20252026)
  expect_equal(nhl_season(2025), 20252026)
  expect_equal(nhl_season("2025/2026"), 20252026)
  expect_equal(nhl_season(date = as.Date("2026-01-15")), 20252026)
  expect_equal(nhl_season(date = as.Date("2026-08-02")), 20262027)
  expect_error(nhl_season("next year"), "season")
})

test_that("game types map to the NHL's codes", {
  expect_equal(nhl_game_type("regular"), 2L)
  expect_equal(nhl_game_type("playoffs"), 3L)
  expect_equal(nhl_game_type(1), 1L)
  expect_error(nhl_game_type("exhibition"))
})

test_that("teams resolve by abbreviation or id", {
  expect_equal(bluelineR:::team_lookup("edm"), "EDM")
  expect_equal(bluelineR:::team_lookup("EDM", "team_id"), 22)
  expect_equal(bluelineR:::team_lookup(68), "UTA")
  expect_error(bluelineR:::team_lookup("XYZ"), "Unknown team")
  expect_equal(nrow(nhl_team_info()), 32)
  expect_false(anyDuplicated(nhl_team_info()$team_id) > 0)
})

test_that("names become snake_case", {
  expect_equal(bluelineR:::to_snake(c("xCoord", "awaySOG", "savePctg5v5Details", "periodDescriptor.number", "TOI5V5", "Faceoffs5V4Won")),
               c("x_coord", "away_sog", "save_pctg_5v5_details", "period_descriptor_number", "toi_5v5", "faceoffs_5v4_won"))
})

test_that("clocks become seconds", {
  expect_equal(bluelineR:::clock_seconds(c("12:34", "00:05", NA, "bad")), c(754, 5, NA, NA))
})

test_that("tidy_json flattens records, keeps English text and drops French copies", {
  recs <- list(
    list(playerId = 1, firstName = list(default = "Connor", fr = "Connor"), team = list(abbrev = "EDM"),
         highlightClip = 1, highlightClipFr = 2, assists = list(1, 2)),
    list(playerId = 2, firstName = list(default = "Leon"), team = list(abbrev = "EDM"))
  )
  out <- tidy_json(recs)
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("player_id", "first_name", "team_abbrev", "highlight_clip", "assists"))
  expect_equal(out$first_name, c("Connor", "Leon"))
  expect_equal(out$highlight_clip, c(1, NA))
  expect_type(out$assists, "list")

  nested <- tidy_json(list(gameDate = "2026-10-20", games = recs))
  expect_named(nested, c("info", "games"))
  expect_equal(nested$info$game_date, "2026-10-20")
})
