#' NHL clubs
#'
#' The 32 current clubs: abbreviation, the NHL's team id (used by the stats
#' and EDGE endpoints), name, conference, division and two club colors.
#'
#' @return A tibble with one row per club.
#' @export
#' @examples
#' nhl_team_info()
nhl_team_info <- function() {
  tibble::tibble(
    abbrev = c("ANA", "BOS", "BUF", "CAR", "CBJ", "CGY", "CHI", "COL", "DAL", "DET", "EDM",
               "FLA", "LAK", "MIN", "MTL", "NJD", "NSH", "NYI", "NYR", "OTT", "PHI", "PIT",
               "SEA", "SJS", "STL", "TBL", "TOR", "UTA", "VAN", "VGK", "WPG", "WSH"),
    team_id = c(24, 6, 7, 12, 29, 20, 16, 21, 25, 17, 22, 13, 26, 30, 8, 1, 18, 2, 3, 9, 4, 5,
                55, 28, 19, 14, 10, 68, 23, 54, 52, 15),
    name = c("Anaheim Ducks", "Boston Bruins", "Buffalo Sabres", "Carolina Hurricanes",
             "Columbus Blue Jackets", "Calgary Flames", "Chicago Blackhawks", "Colorado Avalanche",
             "Dallas Stars", "Detroit Red Wings", "Edmonton Oilers", "Florida Panthers",
             "Los Angeles Kings", "Minnesota Wild", "Montr\u00e9al Canadiens", "New Jersey Devils",
             "Nashville Predators", "New York Islanders", "New York Rangers", "Ottawa Senators",
             "Philadelphia Flyers", "Pittsburgh Penguins", "Seattle Kraken", "San Jose Sharks",
             "St. Louis Blues", "Tampa Bay Lightning", "Toronto Maple Leafs", "Utah Mammoth",
             "Vancouver Canucks", "Vegas Golden Knights", "Winnipeg Jets", "Washington Capitals"),
    conference = c("Western", "Eastern", "Eastern", "Eastern", "Eastern", "Western", "Western",
                   "Western", "Western", "Eastern", "Western", "Eastern", "Western", "Western",
                   "Eastern", "Eastern", "Western", "Eastern", "Eastern", "Eastern", "Eastern",
                   "Eastern", "Western", "Western", "Western", "Eastern", "Eastern", "Western",
                   "Western", "Western", "Western", "Eastern"),
    division = c("Pacific", "Atlantic", "Atlantic", "Metropolitan", "Metropolitan", "Pacific",
                 "Central", "Central", "Central", "Atlantic", "Pacific", "Atlantic", "Pacific",
                 "Central", "Atlantic", "Metropolitan", "Central", "Metropolitan", "Metropolitan",
                 "Atlantic", "Metropolitan", "Metropolitan", "Pacific", "Pacific", "Central",
                 "Atlantic", "Atlantic", "Central", "Pacific", "Pacific", "Central", "Metropolitan"),
    primary_color = c("#F47A38", "#FFB81C", "#002654", "#CE1126", "#002654", "#C8102E", "#CF0A2C",
                      "#6F263D", "#006847", "#CE1126", "#041E42", "#041E42", "#111111", "#A6192E",
                      "#AF1E2D", "#CE1126", "#FFB81C", "#00539B", "#0038A8", "#C52032", "#F74902",
                      "#CFC493", "#001628", "#006D75", "#002F87", "#002868", "#00205B", "#7AB2E1",
                      "#00205B", "#B4975A", "#041E42", "#041E42"),
    secondary_color = c("#B9975B", "#000000", "#FCB514", "#A4A9AD", "#CE1126", "#F1BE48", "#FF671B",
                        "#236192", "#8F8F8C", "#FFFFFF", "#FF4C00", "#C8102E", "#A2AAAD", "#154734",
                        "#192168", "#000000", "#041E42", "#F47D30", "#CE1126", "#C2912C", "#000000",
                        "#FCB514", "#99D9D9", "#EA7200", "#FCB514", "#FFFFFF", "#FFFFFF", "#010101",
                        "#00843D", "#333F42", "#004C97", "#C8102E")
  )
}

team_lookup <- function(team, to = c("abbrev", "team_id")) {
  to <- match.arg(to)
  info <- nhl_team_info()
  key <- toupper(as.character(team))
  i <- match(key, info$abbrev)
  if (is.na(i)) i <- match(suppressWarnings(as.numeric(team)), info$team_id)
  if (is.na(i)) cli::cli_abort("Unknown team {.val {team}}; use an abbreviation like {.val EDM} or a team id.")
  info[[to]][[i]]
}
