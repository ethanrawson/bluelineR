test_that("nhl_coaches() reads careers, clubs and bios", {
  calls <- local_nhl(c("site/api/coach-career-records" = "records-coach-career",
                       "site/api/coach-franchise-records" = "records-coach-franchise",
                       "site/api/coach" = "records-coach"))
  car <- nhl_coaches()
  expect_equal(calls$log[[1]]$query$cayenneExp, "gameTypeId=2")
  expect_equal(car$name[1], "Scotty Bowman")
  expect_true(all(diff(car$wins) <= 0))
  expect_true(all(c("name", "active", "teams", "games", "wins", "stanley_cups") %in% names(car)))
  nhl_coaches("career", "playoffs")
  expect_equal(calls$log[[2]]$query$cayenneExp, "gameTypeId=3")

  # Active coaches by club: only the club each has now.
  now <- nhl_coaches("team", active = TRUE)
  expect_setequal(paste(now$name, now$team), c("Lindy Ruff BUF", "Jon Cooper TBL"))
  expect_s3_class(now$last_coached_date, "Date")
  expect_equal(sum(nhl_coaches("team")$name == "Scotty Bowman"), 5)

  bio <- nhl_coaches("bio")
  expect_equal(bio$name, sort(bio$name))
  expect_false(any(c("bio", "description") %in% names(bio)))
  expect_s3_class(bio$birth_date, "Date")
})

test_that("nhl_general_managers() gives each club's code", {
  local_nhl(c("site/api/general-manager-franchise-records" = "records-gm-franchise"))
  g <- nhl_general_managers("team")
  expect_setequal(g$team, c("EDM", "DET", "DAL", "LAK"))
  now <- nhl_general_managers("team", active = TRUE)
  expect_setequal(paste(now$name, now$team), c("Jim Nill DAL", "Ken Holland LAK"))
  expect_s3_class(now$start_date, "Date")
})
