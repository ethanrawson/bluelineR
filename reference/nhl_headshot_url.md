# Headshot, logo and jersey URLs

Image URLs on the NHL's asset server: a player's headshot in a given
season's sweater (or his latest), a club's logo, and its jersey texture,
a 96-pixel square of sweater mesh in the club's colour that tiles
seamlessly (NHL.com fills player cards with it); `"NHL"` gives the
league's own.

## Usage

``` r
nhl_headshot_url(player_id, team = NULL, season = NULL)

nhl_logo_url(team, variant = c("light", "dark"))

nhl_jersey_url(team)
```

## Arguments

- player_id:

  NHL player id.

- team:

  Club abbreviation; needed with `season`.

- season:

  Season for the headshot; `NULL` for the latest one.

- variant:

  `"light"` (for light backgrounds) or `"dark"`.

## Value

A URL.

## See also

[`nhl_broadcasts()`](https://ethanrawson.github.io/bluelineR/reference/nhl_broadcasts.md)
for broadcasters' logos.

## Examples

``` r
nhl_headshot_url(8478402)
#> [1] "https://assets.nhle.com/mugs/nhl/latest/8478402.png"
nhl_headshot_url(8478402, "EDM", "2016-17")
#> [1] "https://assets.nhle.com/mugs/nhl/20162017/EDM/8478402.png"
nhl_logo_url("EDM", "dark")
#> [1] "https://assets.nhle.com/logos/nhl/svg/EDM_dark.svg"
nhl_jersey_url("EDM")
#> [1] "https://assets.nhle.com/textures/nhl/jersey/png/EDM.png"
```
