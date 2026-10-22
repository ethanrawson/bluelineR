test_that("nhl_stats builds the Cayenne query", {
  calls <- local_nhl(c("skater/summary" = "stats-skater-summary"))
  s <- nhl_stats("skater/summary", "2025-26", sort = "points", limit = 5, filter = "teamAbbrevs='EDM'")
  expect_equal(nrow(s), 5)
  expect_equal(names(s)[1:2], c("player_id", "skater_full_name"))
  q <- calls$log[[1]]$query
  expect_equal(q$cayenneExp, "seasonId=20252026 and gameTypeId=2 and teamAbbrevs='EDM'")
  expect_equal(as.character(q$sort), '[{"property":"points","direction":"DESC"}]')
  nhl_stats("skater/summary", c(2015, 2025), aggregate = TRUE, sort = "+points")
  q2 <- calls$log[[2]]$query
  expect_equal(q2$cayenneExp, "seasonId>=20152016 and seasonId<=20252026 and gameTypeId=2")
  expect_equal(q2$isAggregate, "true")
  expect_match(as.character(q2$sort), "ASC")
})

test_that("records, draft rankings and picks", {
  local_nhl(c("site/api/officials" = "records-officials", "draft/rankings/2026/1" = "draft-rankings-2026-1"))
  o <- nhl_records("officials")
  expect_equal(nrow(o), 5)
  d <- nhl_draft_rankings(2026)
  expect_equal(unique(d$draft_year), 2026)
  expect_equal(nrow(d), 15)
})
