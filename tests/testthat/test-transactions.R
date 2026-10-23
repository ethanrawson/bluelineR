test_that("nhl_signings() reads contracts, and their seasons", {
  calls <- local_nhl(c("stats-api.sportsnet.ca/signings" = "sportsnet-signings"))
  s <- nhl_signings(2026)
  expect_equal(calls$log[[1]]$query$signing_year, 2026)
  expect_equal(nrow(s), 3)
  k <- s[s$player_name == "Marat Khusnutdinov", ]
  expect_equal(k$team, "BOS")
  expect_equal(k$contract_length, 3)
  expect_equal(k$aav, 3950000)
  expect_equal(c(k$signing_status, k$expiry_status), c("RFA", "UFA"))
  expect_s3_class(s$signing_date, "Date")
  expect_true(all(diff(s$signing_date) <= 0))

  by <- nhl_signings(2026, by_season = TRUE)
  kb <- by[by$player_name == "Marat Khusnutdinov", ]
  expect_equal(kb$season, c(20272028, 20282029, 20292030))
  expect_equal(kb$cap_hit, rep(3950000, 3))
  expect_equal(kb$base_salary, c(2200000, 3800000, 3850000))
  expect_equal(kb$signing_bonus, c(1500000, 500000, 0))
})

test_that("nhl_trades() gives trades, or every asset moved, in NHL codes", {
  local_nhl(c("stats-api.sportsnet.ca/trades" = "sportsnet-trades"))
  t <- nhl_trades()
  expect_equal(nrow(t), 3)
  expect_equal(t$season, rep(20262027, 3))
  # Sportsnet writes Nashville as NAS; the NHL's code is NSH.
  expect_true("NSH, MTL" %in% t$teams)
  expect_equal(nrow(nhl_trades("2025-26")), 0)

  a <- nhl_trades(assets = TRUE)
  pick <- a[a$asset_type == "draft_pick" & a$team == "MTL", ]
  expect_equal(c(pick$pick_year, pick$pick_round), c(2027, 2))
  expect_equal(pick$pick_original_team, "VGK")
  expect_true(is.na(pick$player_name))
  merz <- a[a$player_name %in% "Elvis Merzlikins", ]
  expect_equal(merz$team, "TOR")
  expect_equal(merz$retained_hit, 972000)
  expect_true(all(is.na(a$pick_original_team[a$asset_type == "player"])))
})

test_that("espn_transactions() and espn_injuries()", {
  calls <- local_nhl(c("/transactions" = "espn-transactions", "/injuries" = "espn-injuries"))
  tx <- espn_transactions(2026)
  expect_equal(calls$log[[1]]$query$season, 2026)
  expect_equal(nrow(tx), 4)
  expect_equal(tx$action[tx$team == "WSH"], "signed")
  expect_true(all(diff(tx$date) <= 0))

  inj <- espn_injuries()
  expect_equal(nrow(inj), 4)
  expect_setequal(unique(inj$team), c("ANA", "BUF"))
  expect_equal(inj$espn_id[inj$player_name == "Jeff Malott"], 4895214)
  expect_s3_class(inj$return_date, "Date")
})
