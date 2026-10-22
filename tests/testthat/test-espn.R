test_that("devig() takes the margin out of a two-way market", {
  expect_equal(devig(-110, -110), 0.5)
  expect_equal(round(devig(-150, 130), 4), round((150 / 250) / (150 / 250 + 100 / 230), 4))
  expect_true(is.na(devig(NA, -110)))
  expect_equal(length(devig(c(-110, -200), c(-110, 170))), 2)
})

test_that("espn_odds() reads DraftKings' lines from the scoreboard", {
  local_nhl(c("scoreboard" = "espn-scoreboard-20261022"))
  o <- espn_odds("2026-10-22")
  expect_equal(nrow(o), 2)
  bos <- o[o$home_team == "BOS", ]
  expect_equal(bos$away_team, "NSH")
  expect_equal(c(bos$home_ml, bos$away_ml, bos$home_ml_open), c(-155, 130, -166))
  expect_equal(bos$total_line, 5.5)
  expect_equal(c(bos$over_price, bos$under_price), c(-130, 110))
  expect_equal(bos$home_puck_line, -1.5)
  expect_equal(bos$home_win_prob, devig(-155, 130))
  expect_equal(bos$provider, "DraftKings")
})

test_that("espn_props() pairs over and under, names players and finds their NHL ids", {
  local_nhl(c(
    "scoreboard" = "espn-scoreboard-20261021",
    "propBets" = "espn-propbets-401892550",
    "teams/15/roster" = "espn-roster-15",
    "teams/2/roster" = "espn-roster-2",
    "roster/PHI/current" = "roster-PHI-current",
    "roster/BUF/current" = "roster-BUF-current"
  ))
  p <- espn_props("2026-10-21")
  sog <- p[p$market == "Total Shots on Goal" & p$player_name %in% "Sean Couturier", ]
  expect_equal(nrow(sog), 1)
  expect_equal(c(sog$line, sog$over, sog$under), c(1.5, 110, -150))
  expect_equal(sog$stat, "shots")
  expect_equal(sog$team, "PHI")
  expect_equal(sog$player_id, 8476461L)
  expect_equal(sog$over_prob, devig(110, -150))
  goal <- p[p$market == "Anytime Goalscorer" & p$player_name %in% "Sean Couturier", ]
  expect_equal(goal$over, 550)
  expect_true(is.na(goal$under))
  # Club goal totals come through; period lines do not.
  expect_true(any(p$stat %in% "team_goals"))
  expect_false(any(grepl("Period", p$market)))
  expect_true(mean(!is.na(p$player_id[!is.na(p$player_name)])) > 0.9)
})

test_that("espn_player_splits() turns ESPN's split tables into rows", {
  local_nhl(c("athletes/3895074/splits" = "espn-splits-3895074"))
  s <- espn_player_splits(3895074)
  expect_true(all(c("category", "split", "games", "goals", "assists", "points") %in% names(s)))
  expect_equal(s$split[1], "All Splits")
  expect_true(is.numeric(s$points))
  expect_true("by_opponent" %in% s$category)
})

test_that("fold_accents() works without a UTF-8 locale", {
  expect_equal(fold_accents(c("Stützle", "Šimon", "Jiří", "Groß", NA)), c("stutzle", "simon", "jiri", "gross", NA))
})
