test_that("requests carry the user agent and fail with classed errors", {
  req <- bluelineR:::build_request("https://api-web.nhle.com/v1/score/now", query = list(a = 1, b = NULL))
  expect_match(req$options$useragent, "^bluelineR/")
  expect_match(req$url, "a=1$")

  httr2::local_mocked_responses(function(req) httr2::response(status_code = 404))
  expect_error(bluelineR:::fetch_json("https://api-web.nhle.com/v1/nope"), class = "bluelineR_not_found")
})

test_that("the cache answers a repeat request without the network", {
  withr::local_options(bluelineR.cache = TRUE)
  nhl_cache_clear()
  n <- 0
  httr2::local_mocked_responses(function(req) {
    n <<- n + 1
    httr2::response_json(body = list(ok = TRUE))
  })
  expect_equal(bluelineR:::fetch_json("https://api-web.nhle.com/v1/x"), list(ok = TRUE))
  expect_equal(bluelineR:::fetch_json("https://api-web.nhle.com/v1/x"), list(ok = TRUE))
  expect_equal(n, 1)
  nhl_cache_clear()
})

test_that("nhl_api reaches every API", {
  calls <- local_nhl(c("score/now" = "score-2026-10-20", "glossary" = "records-officials"))
  nhl_api("score/now")
  out <- nhl_api("/glossary", api = "stats", tidy = TRUE)
  expect_s3_class(out$data, "tbl_df")
  expect_equal(calls$log[[2]]$url, "https://api.nhle.com/stats/rest/en/glossary")
})
