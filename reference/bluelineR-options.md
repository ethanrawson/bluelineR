# Package options

- `bluelineR.rate`: requests per second, at most (default 5).

- `bluelineR.max_tries`: attempts per request, retrying rate limits
  (HTTP 429) and server errors with backoff (default 4).

- `bluelineR.cache`: keep responses in memory for the session, so asking
  twice costs one request (default `FALSE`). Clear it with
  [`nhl_cache_clear()`](https://ethanrawson.github.io/bluelineR/reference/nhl_cache_clear.md).

- `bluelineR.user_agent`: the User-Agent sent with each request.
