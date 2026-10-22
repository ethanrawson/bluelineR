test_that("tournament stats are tagged, filtered and sorted", {
  local_nhl(c("international-skater-tournament-record" = "records-intl-skater-tournament"))
  all <- nhl_international("skater")
  expect_setequal(unique(all$tournament), c("Canada Cup", "4 Nations Face-Off", "Olympics"))
  expect_equal(sort(unique(all$year)), c(1987, 2025, 2026))
  expect_equal(names(all)[1:3], c("tournament", "year", "season"))
  # No skater ice time before 2010.
  expect_true(all(is.na(all$toi_seconds[all$year == 1987])))
  oly <- nhl_international("skater", "Olympics", 2026)
  expect_equal(nrow(oly), 5)
  expect_equal(oly$last_name[1], "McDavid")
  expect_true(all(diff(oly$points) <= 0))
  cc <- nhl_international("skater", "canada cup")
  expect_equal(paste(cc$first_name, cc$last_name), c("Wayne Gretzky", "Mario Lemieux", "Claude Lemieux"))
  expect_equal(nrow(nhl_international("skater", year = 2030)), 0)
  expect_error(nhl_international("skater", "spengler"), "tournament")
})

test_that("games get club codes, and the 4 Nations final counts as the 4 Nations", {
  local_nhl(c("international-playoff-series-details" = "records-intl-games",
              "international-team-tournament-record" = "records-intl-team-tournament"))
  g <- nhl_international_games("4 nations")
  expect_equal(nrow(g), 7)
  final <- g[g$series_title == "Final", ]
  expect_equal(final$game_id, 2024200007)
  expect_equal(c(final$visiting_team, final$home_team, final$winning_team), c("CAN", "USA", "CAN"))
  expect_s3_class(g$game_date, "Date")
  oly <- nhl_international_games("olympics", 2026)
  expect_equal(sort(oly$series_title), c("Bronze Medal Game", "Gold Medal Game"))
  expect_false(any(oly$overtime %in% ""))
})

test_that("careers, winners and podiums", {
  local_nhl(c("international-skater-career-record" = "records-intl-skater-career",
              "olympic-goaltender-career-record" = "records-olympic-goalie-career",
              "international-tournament-winner" = "records-intl-winners",
              "olympic-tournament-winner" = "records-olympic-podiums"))
  car <- nhl_international_careers("skater")
  expect_equal(car$last_name[1], "Gretzky")
  goalies <- nhl_international_careers("goalie", olympics = TRUE)
  expect_true("gold_medals" %in% names(goalies))
  expect_true(all(diff(goalies$wins) <= 0))
  w <- nhl_international_winners()
  expect_equal(nrow(w), 15)
  expect_equal(w$year[w$tournament == "World Cup of Hockey"], c(1996, 2004, 2016))
  expect_equal(w$winning_tricode[w$year == 2026], "USA")
  expect_true(all(is.na(w$overtime) | w$overtime %in% c("OT", "SO")))
  p <- nhl_olympic_podiums()
  expect_equal(p$year, c(1998, 2002, 2006, 2010, 2014, 2026))
  expect_equal(p$gold_medalist_tricode[p$year == 2026], "USA")
})
