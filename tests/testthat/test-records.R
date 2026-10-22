test_that("nhl_draft_lottery() names the winners and the clubs", {
  calls <- local_nhl(c("draft-lottery-picks" = "records-draft-lottery-2026"))
  d <- nhl_draft_lottery(2026)
  expect_equal(d$pick, 1:2)
  expect_equal(d$player_name[1], "Gavin McKenna")
  expect_equal(d$lottery_team[1], "TOR")
  expect_match(d$effect[1], "to 1st")
  q <- calls$log[[1]]$query
  expect_equal(q$cayenneExp, "draftYear=2026")
  expect_true("draftTeam.triCode" %in% unlist(q[names(q) == "include"]))
})

test_that("nhl_draft_lottery_odds() reads the odds tables, seeded or not", {
  local_nhl(c("draft-lottery-odds" = "records-draft-lottery-odds-1995"))
  o <- nhl_draft_lottery_odds(1995)
  expect_equal(nrow(o), 10)
  expect_equal(o$seed, 1:10)
  expect_equal(o$team[1], "Ottawa Senators")
  expect_equal(o$odds[1], 0.30)
  expect_equal(sum(o$odds), 1, tolerance = 1e-6)

  local_nhl(c("draft-lottery-odds" = "records-draft-lottery-odds-2005"))
  o <- nhl_draft_lottery_odds(2005)
  expect_equal(nrow(o), 30)
  expect_true(all(is.na(o$seed)))
})

test_that("nhl_draft_lottery_odds() points to the image when there is no table", {
  local_nhl(c("draft-lottery-odds" = "records-draft-lottery-odds-2024"))
  expect_message(o <- nhl_draft_lottery_odds(2024), "image")
  expect_equal(nrow(o), 0)
  expect_named(o, c("draft_year", "seed", "team", "odds"))
})

test_that("nhl_franchise_records() reads the Game 7, outdoor and season-opener tables", {
  local_nhl(c("game-7" = "records-game7", "neutral-site" = "records-outdoor",
              "season-opener" = "records-season-opener", "stats/rest/en/franchise" = "stats-franchise"))
  g7 <- nhl_franchise_records("game7")
  expect_false(anyNA(g7$franchise_name))
  expect_true(all(diff(g7$games_played) <= 0))
  expect_true(all(c("games_played", "wins", "losses", "home_wins", "road_wins") %in% names(g7)))
  expect_false("id" %in% names(g7))

  od <- nhl_franchise_records("outdoor")
  expect_true(nrow(od) > 0)
  expect_true("venues" %in% names(od))
  expect_false("outdoor" %in% names(od))

  so <- nhl_franchise_records("season_opener")
  expect_setequal(so$venue, c("home", "road", "all"))
  expect_setequal(unique(so$franchise_name), c("Montréal Canadiens", "Boston Bruins"))
})

test_that("nhl_franchise_records() filters overtime by game type", {
  calls <- local_nhl(c("overtime" = "records-game7"))
  nhl_franchise_records("overtime", game_type = "playoffs")
  expect_equal(calls$log[[1]]$query$cayenneExp, "gameTypeId=3")
})

test_that("nhl_milestones() says how far each player has to go", {
  local_nhl(c("milestones/skaters" = "milestones-skaters", "milestones/goalies" = "milestones-goalies"))
  m <- nhl_milestones()
  expect_equal(m$player_name[1], "Ryan Ellis")
  expect_equal(m$current[1], 199)
  expect_equal(m$to_go[1], 1)
  expect_true(all(diff(m$to_go) >= 0))
  expect_setequal(m$game_type, c("regular", "playoffs"))

  g <- nhl_milestones("goalie")
  expect_false(anyNA(g$current))
  expect_equal(g$to_go[g$player_name == "Juuse Saros"], 3)
})

test_that("nhl_records_catalog() lists the resources and filters them", {
  cat <- nhl_records_catalog()
  expect_named(cat, c("resource", "about", "helper"))
  expect_false(anyDuplicated(cat$resource) > 0)
  expect_true(all(c("draft", "officials", "draft-lottery-picks") %in% cat$resource))
  expect_equal(nhl_records_catalog("lottery")$resource, c("draft-lottery-odds", "draft-lottery-odds-all-time", "draft-lottery-picks"))
  helpers <- sub("\\(.*", "", stats::na.omit(cat$helper))
  expect_true(all(vapply(helpers, exists, logical(1), envir = asNamespace("bluelineR"))))
})

test_that("nhl_jersey_url() builds texture URLs", {
  expect_equal(nhl_jersey_url("edm"), "https://assets.nhle.com/textures/nhl/jersey/png/EDM.png")
  expect_equal(nhl_jersey_url("NHL"), "https://assets.nhle.com/textures/nhl/jersey/png/NHL.png")
  expect_error(nhl_jersey_url("XYZ"), "Unknown team")
})

test_that("html_text() strips tags and decodes entities", {
  expect_equal(html_text("<td style='x'>Montr&eacute;al&nbsp;Canadiens</td>"), "Montréal Canadiens")
  expect_equal(html_text("Kings &#38; Ducks"), "Kings & Ducks")
})
