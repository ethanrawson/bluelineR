test_that("tracking frames parse to feet in the play-by-play's orientation", {
  fr <- mcdavid_goal()
  expect_s3_class(fr, "tbl_df")
  expect_equal(attr(fr, "game_id"), 2025020534)
  expect_equal(max(fr$frame), 140)
  expect_true(all(abs(fr$x) <= 101 & abs(fr$y) <= 43))
  expect_equal(sum(fr$is_puck & fr$frame == 1), 1)
  expect_setequal(stats::na.omit(unique(fr$team)), c("EDM", "BOS"))
})

test_that("goal_frame finds the puck in the net, not a blip", {
  expect_equal(goal_frame(mcdavid_goal()), 99)
})

test_that("classify_goal reads McDavid's shorthanded breakaway", {
  cl <- classify_goal(mcdavid_goal(), team = "EDM", shot_type = "backhand")
  expect_true(cl$rush)
  expect_true(cl$breakaway)
  expect_false(cl$oddman)
  expect_false(cl$onetimer)
  expect_equal(cl$shooter, 8478402)
  expect_equal(cl$distance, 7.5)
  expect_equal(cl$shot_speed, 24.1)
  expect_equal(cl$kinds, "rush, breakaway")
  # The scoring club and the goalies can be worked out from the frames.
  expect_equal(classify_goal(mcdavid_goal())$kinds, cl$kinds)
})

test_that("skater_speed tops out with McDavid", {
  sp <- skater_speed(mcdavid_goal())
  top <- sp[which.max(sp$speed_mph), ]
  expect_equal(top$player_id, 8478402)
  expect_equal(round(top$speed_mph, 1), 20.3)
})

test_that("nhl_goal_tracking asks as nhl.com and nhl_goal_replay reads the goal", {
  seen <- list()
  local_mocked_bindings(fetch_json = function(url, query = list(), headers = list()) {
    seen[[length(seen) + 1]] <<- list(url = url, headers = headers)
    if (grepl("wsr.nhle.com/sprites/20252026/2025020534/ev777.json", url, fixed = TRUE)) {
      con <- gzfile(system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR"), "rt")
      on.exit(close(con))
      return(jsonlite::fromJSON(paste(readLines(con, warn = FALSE), collapse = ""), simplifyVector = FALSE))
    }
    if (grepl("ppt-replay/goal/2025020534/777", url, fixed = TRUE)) return(fixture("ppt-replay-2025020534-777"))
    stop("No fixture for ", url)
  })
  fr <- nhl_goal_tracking(2025020534, 777)
  expect_equal(nrow(fr), nrow(mcdavid_goal()))
  expect_equal(seen[[1]]$headers$Referer, "https://www.nhl.com/")
  r <- nhl_goal_replay(2025020534, 777)
  expect_equal(r$last_name, "McDavid")
  expect_equal(r$strength, "sh")
  expect_s3_class(r$assists[[1]], "tbl_df")
  expect_match(r$away_logo, "EDM_light.svg", fixed = TRUE)
  expect_match(r$home_logo_dark, "BOS_dark.svg", fixed = TRUE)
})

test_that("goal_context finds rebounds and faceoff goals", {
  local_nhl(c("play-by-play" = "pbp-2025020534"))
  p <- nhl_pbp(2025020534)
  ctx <- goal_context(p, 777)
  expect_named(ctx, c("event_id", "rebound", "faceoff"))
  expect_error(goal_context(p, 1), "No goal")
})
