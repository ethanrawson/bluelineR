# HTTP: one place builds every request, so throttling, retries, caching and
# errors behave the same for every endpoint.

api_base <- function(api) {
  switch(api,
    web = "https://api-web.nhle.com/v1",
    stats = "https://api.nhle.com/stats/rest/en",
    records = "https://records.nhl.com/site/api",
    search = "https://search.d3.nhle.com/api/v1",
    tracking = "https://wsr.nhle.com/sprites",
    cli::cli_abort("Unknown API {.val {api}}.")
  )
}

api_url <- function(api, ...) {
  parts <- vapply(list(...), function(p) utils::URLencode(as.character(p)), character(1))
  paste(c(api_base(api), parts), collapse = "/")
}

user_agent <- function() {
  getOption(
    "bluelineR.user_agent",
    sprintf("bluelineR/%s (https://github.com/ethanrawson/bluelineR)", utils::packageVersion("bluelineR"))
  )
}

.cache <- new.env(parent = emptyenv())

#' Clear the response cache
#'
#' Empties the in-memory cache used when `options(bluelineR.cache = TRUE)`.
#'
#' @return `NULL`, invisibly.
#' @export
#' @examples
#' nhl_cache_clear()
nhl_cache_clear <- function() {
  rm(list = ls(.cache, all.names = TRUE), envir = .cache)
  invisible(NULL)
}

compact <- function(x) x[!vapply(x, is.null, logical(1))]

build_request <- function(url, query = list(), headers = list()) {
  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, user_agent())
  query <- compact(query)
  if (length(query)) req <- httr2::req_url_query(req, !!!query)
  if (length(headers)) req <- httr2::req_headers(req, !!!headers)
  req <- httr2::req_throttle(req, rate = getOption("bluelineR.rate", 5), realm = "nhl")
  req <- httr2::req_retry(
    req,
    max_tries = getOption("bluelineR.max_tries", 4),
    is_transient = function(resp) httr2::resp_status(resp) %in% c(429, 500, 502, 503, 504),
    backoff = function(i) min(2^i, 30)
  )
  httr2::req_error(req, is_error = function(resp) FALSE)
}

# GET a URL and parse its JSON (lists, not data frames: the parsers below
# decide the shape). Tests replace this one function with fixtures.
fetch_json <- function(url, query = list(), headers = list()) {
  key <- paste(url, paste(names(query), unlist(query), sep = "=", collapse = "&"))
  if (isTRUE(getOption("bluelineR.cache", FALSE)) && exists(key, envir = .cache, inherits = FALSE)) {
    return(get(key, envir = .cache, inherits = FALSE))
  }
  resp <- httr2::req_perform(build_request(url, query, headers))
  status <- httr2::resp_status(resp)
  if (status == 404) {
    cli::cli_abort(c("The NHL API has nothing at this address (HTTP 404).", i = "{.url {httr2::resp_url(resp)}}"),
                   class = "bluelineR_not_found")
  }
  if (status >= 400) {
    cli::cli_abort(c("The NHL API returned HTTP {status}.", i = "{.url {httr2::resp_url(resp)}}"),
                   class = "bluelineR_http_error")
  }
  body <- jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = FALSE)
  if (isTRUE(getOption("bluelineR.cache", FALSE))) assign(key, body, envir = .cache)
  body
}

#' Call any NHL endpoint
#'
#' The escape hatch: a GET against one of the NHL's APIs, returned as parsed
#' JSON (nested lists). Every other function in the package is built on it.
#'
#' @param path Path below the API's base URL, e.g. `"score/now"`.
#' @param api Which API: `"web"` (`api-web.nhle.com/v1`), `"stats"`
#'   (`api.nhle.com/stats/rest/en`), `"records"` (`records.nhl.com/site/api`)
#'   or `"search"` (`search.d3.nhle.com/api/v1`).
#' @param query Named list of query parameters.
#' @param tidy If `TRUE`, the result goes through [tidy_json()].
#' @return The parsed response.
#' @export
#' @examplesIf interactive()
#' nhl_api("partner-game/US/now")
#' nhl_api("glossary", api = "stats", tidy = TRUE)
nhl_api <- function(path, api = c("web", "stats", "records", "search"), query = list(), tidy = FALSE) {
  api <- match.arg(api)
  out <- fetch_json(paste0(api_base(api), "/", sub("^/", "", path)), query = query)
  if (tidy) tidy_json(out) else out
}
