# NHL.com news and videos

The stories and videos on NHL.com, newest first, from its content API:
headline, summary or description, date, author, tags (club and season
tags like `"teamid-22"`, players' tags, ...) and the address. Videos
carry their Brightcove id and length.

## Usage

``` r
nhl_news(tag = NULL, limit = 20, language = "en-us")

nhl_videos(tag = NULL, limit = 20, language = "en-us")
```

## Arguments

- tag:

  Only items with this tag (a slug, e.g. `"teamid-22"` or `"goals"`);
  `NULL` for everything.

- limit:

  How many items (up to 100).

- language:

  Locale, e.g. `"en-us"` or `"fr-ca"`.

## Value

A tibble, one row per item.

## Examples

``` r
if (FALSE) { # interactive()
nhl_news(limit = 5)
nhl_videos(tag = "teamid-22", limit = 5)
}
```
