# Saved API responses (tests/testthat/fixtures), so the tests run offline.
fixture <- function(name) {
  jsonlite::fromJSON(test_path("fixtures", paste0(name, ".json")), simplifyVector = FALSE)
}

# Serve fetch_json() from fixtures: the first route whose text appears in the
# URL picks the file. Every call is recorded in the returned environment.
local_nhl <- function(routes, env = parent.frame()) {
  calls <- new.env()
  calls$log <- list()
  testthat::local_mocked_bindings(
    fetch_json = function(url, query = list(), headers = list()) {
      calls$log[[length(calls$log) + 1]] <- list(url = url, query = query, headers = headers)
      for (pat in names(routes)) if (grepl(pat, url, fixed = TRUE)) return(fixture(routes[[pat]]))
      stop("No fixture for ", url)
    },
    .env = env
  )
  calls
}

mcdavid_goal <- function() {
  read_goal_tracking(system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR"), 2025020534, 777)
}

# Serve fetch_text() (HTML pages: the IIHF's schedules) from fixture files.
local_pages <- function(routes, env = parent.frame()) {
  testthat::local_mocked_bindings(
    fetch_text = function(url, query = list(), headers = list()) {
      for (pat in names(routes)) if (grepl(pat, url, fixed = TRUE)) {
        return(paste(readLines(test_path("fixtures", routes[[pat]]), warn = FALSE), collapse = "\n"))
      }
      stop("No fixture for ", url)
    },
    .env = env
  )
}
