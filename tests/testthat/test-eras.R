test_that("nhl_stat_eras() lists the eras in order and each stat's first season", {
  eras <- nhl_stat_eras()
  expect_named(eras, c("from", "to", "adds", "functions"))
  expect_true(all(grepl("^\\d{4}-\\d{2}$", eras$from)))
  expect_false(is.unsorted(eras$from))
  expect_equal(eras$from[1], "1917-18")

  st <- nhl_stat_eras("stat")
  expect_named(st, c("report", "stat", "first_season"))
  expect_true(all(grepl("^\\d{4}-\\d{2}$", st$first_season)))
  expect_false(anyDuplicated(paste(st$report, st$stat)) > 0)
  shots <- nhl_stat_eras("stat", "shots")
  expect_equal(shots$first_season[shots$report == "skater/summary"], "1959-60")
})

test_that("stat_first_season() and season_label() agree with the table", {
  expect_equal(stat_first_season("skater/summary", "shots"), 19591960)
  expect_equal(stat_first_season("skater/realtime", "hits"), 20052006)
  expect_null(stat_first_season("skater/summary", "no_such_stat"))
  expect_equal(season_label(19992000), "1999-00")
  expect_equal(season_label(20252026), "2025-26")
})

test_that("nhl_stats() says when a sort stat was not kept that far back", {
  local_nhl(c("skater/" = "stats-skater-summary"))
  expect_message(nhl_stats("skater/realtime", "1981-82", sort = "hits"), "2005-06")
  expect_message(nhl_stats("skater/summary", c("1950-51", "1970-71"), sort = "plusMinus"), "1959-60")
  expect_no_message(nhl_stats("skater/summary", "1981-82", sort = "points"))
  expect_no_message(nhl_stats("skater/realtime", "2010-11", sort = "hits"))
})

test_that("old play-by-play and missing shift charts get a note", {
  withr::local_options(rlib_message_verbosity = "verbose")
  local_nhl(c("play-by-play" = "pbp-2025020534", "shiftcharts" = "shifts-empty"))
  expect_message(nhl_pbp(1981020100), "goals and penalties only")
  expect_message(nhl_pbp(2001020100), "shots on goal")
  expect_no_message(nhl_pbp(2025020534))
  expect_message(out <- nhl_shifts(2009020100), "2010-11")
  expect_equal(nrow(out), 0)
})
