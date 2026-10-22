# NHL clubs

The 32 current clubs: abbreviation, the NHL's team id (used by the stats
and EDGE endpoints), name, conference, division and two club colors.

## Usage

``` r
nhl_team_info()
```

## Value

A tibble with one row per club.

## Examples

``` r
nhl_team_info()
#> # A tibble: 32 × 7
#>    abbrev team_id name         conference division primary_color secondary_color
#>    <chr>    <dbl> <chr>        <chr>      <chr>    <chr>         <chr>          
#>  1 ANA         24 Anaheim Duc… Western    Pacific  #F47A38       #B9975B        
#>  2 BOS          6 Boston Brui… Eastern    Atlantic #FFB81C       #000000        
#>  3 BUF          7 Buffalo Sab… Eastern    Atlantic #002654       #FCB514        
#>  4 CAR         12 Carolina Hu… Eastern    Metropo… #CE1126       #A4A9AD        
#>  5 CBJ         29 Columbus Bl… Eastern    Metropo… #002654       #CE1126        
#>  6 CGY         20 Calgary Fla… Western    Pacific  #C8102E       #F1BE48        
#>  7 CHI         16 Chicago Bla… Western    Central  #CF0A2C       #FF671B        
#>  8 COL         21 Colorado Av… Western    Central  #6F263D       #236192        
#>  9 DAL         25 Dallas Stars Western    Central  #006847       #8F8F8C        
#> 10 DET         17 Detroit Red… Eastern    Atlantic #CE1126       #FFFFFF        
#> # ℹ 22 more rows
```
