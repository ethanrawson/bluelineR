test_that("iihf_game() reads the 2026 Olympic final", {
  local_nhl(c("GetLatestState/1010000058" = "iihf-1010000058"))
  g <- iihf_game(1010000058)
  expect_equal(nrow(g), 1)
  expect_equal(g$home_team, "CAN")
  expect_equal(g$away_team, "USA")
  expect_equal(c(g$home_score, g$away_score), c(1L, 2L))
  expect_equal(g$ended_in, "overtime")
  expect_equal(g$date, as.Date("2026-02-22"))
  expect_equal(g$shots_located, 135L)
})

test_that("iihf_shots() places every shot and agrees with the official shots on goal", {
  local_nhl(c("GetLatestState/1010000058" = "iihf-1010000058"))
  s <- iihf_shots(1010000058)
  expect_equal(nrow(s), 135)
  expect_identical(attr(s, "source"), "IIHF")
  expect_setequal(unique(s$result), c("goal", "saved", "blocked", "missed"))
  on_goal <- table(s$team[s$result %in% c("goal", "saved")])
  expect_equal(as.integer(on_goal[c("CAN", "USA")]), c(42L, 28L))

  hughes <- s[s$result == "goal" & s$period == "OT", ]
  expect_equal(hughes$player_name, "Jack Hughes")
  expect_equal(hughes$time, "61:41")
  expect_equal(hughes$game_seconds, 61 * 60 + 41)
  expect_equal(hughes$x, 78)                 # 0.890 of a 200 ft rink, from centre ice
  expect_equal(hughes$y, (0.458 - 0.5) * 85)
  expect_equal(round(hughes$distance, 1), 11.6)
  # The shooting team attacks right after turning, in every period.
  expect_true(all(stats::median(s$x_fixed) > 0))
  expect_true(all(tapply(s$x_fixed, paste(s$period, s$team), stats::median) > 0))
  # The columns plot_shots() reads.
  expect_true(all(c("type", "event_team", "x_fixed", "y_fixed") %in% names(s)))
})

test_that("iihf_shots() takes a rink size", {
  local_nhl(c("GetLatestState/1010000058" = "iihf-1010000058"))
  s <- iihf_shots(1010000058, length = 60 * 3.2808, width = 30 * 3.2808)
  hughes <- s[s$result == "goal" & s$period == "OT", ]
  expect_equal(hughes$x, (0.890 - 0.5) * 60 * 3.2808)
})

test_that("iihf_events() has the goals, assists, penalties and goalie changes", {
  local_nhl(c("GetLatestState/1010000058" = "iihf-1010000058"))
  e <- iihf_events(1010000058)
  goals <- e[e$type == "goal", ]
  expect_equal(goals$player_name, c("Matt Boldy", "Cale Makar", "Jack Hughes"))
  expect_equal(goals$assist_1_name, c("Auston Matthews", "Devon Toews", "Zach Werenski"))
  expect_equal(goals$assist_2_name[3], "Connor Hellebuyck")
  expect_equal(goals$away_score, c(1L, 1L, 2L))
  expect_equal(goals$situation, rep("EQ", 3))
  pens <- e[e$type == "penalty", ]
  expect_true(nrow(pens) >= 6)
  expect_true("Hooking" %in% pens$infraction)
  expect_true(all(diff(e$game_seconds[!is.na(e$game_seconds)]) >= 0))
})

test_that("iihf_period_stats() has each team's shots, saves and power play by period", {
  local_nhl(c("GetLatestState/1010000058" = "iihf-1010000058"))
  st <- iihf_period_stats(1010000058)
  tot <- st[st$period == "total", ]
  expect_equal(tot$shots_on_goal, c(42L, 28L))
  expect_equal(tot$team, c("CAN", "USA"))
  expect_equal(st$power_play_seconds[st$period == "1" & st$team == "USA"], 120)
})

test_that("an unknown IIHF game is an error, not an empty table", {
  local_nhl(c("GetLatestState/" = "iihf-null"))
  expect_error(iihf_game(999), class = "bluelineR_not_found")
  expect_error(iihf_game("abc"), "IIHF game id")
})

test_that("iihf_schedule() reads a tournament's games from the schedule page", {
  local_pages(c("events/2026/wm/schedule" = "iihf-schedule-2026-wm.html"))
  s <- iihf_schedule(2026, "wm")
  expect_equal(nrow(s), 4)
  expect_equal(s$event_id[1], "969")
  expect_equal(s$game_id[1:3], c("12857", "12858", "12859"))
  expect_equal(s$game_number[1:3], 1:3)
  expect_equal(c(s$home_team[1], s$away_team[1]), c("FIN", "GER"))
  expect_equal(c(s$home_score[1], s$away_score[1]), c(3L, 1L))
  expect_equal(s$venue[1], "Swiss Life Arena")
  expect_equal(s$group[1], "A")
  expect_equal(s$phase[4], "GoldMedalGame")
  # Finland won the final in overtime: final, with its score.
  expect_true(s$is_final[4] && s$is_overtime[4])
  expect_equal(c(s$home_score[4], s$away_score[4]), c(0L, 1L))
  expect_equal(s$date[1], as.Date("2026-05-15"))
})

test_that("iihf_athlete() keeps Mc and Mac", {
  a <- list(IH_Athlete_Id = "1", Number = "29", Position = "F", GivenName = "Nathan", FamilyName = "MACKINNON",
            ReportingName = "MacKINNON Nathan")
  expect_equal(iihf_athlete(a)$player_name, "Nathan MacKinnon")
  b <- list(GivenName = "Charlie", FamilyName = "MCAVOY", ReportingName = "McAVOY Charlie")
  expect_equal(iihf_athlete(b)$player_name, "Charlie McAvoy")
  expect_true(is.na(iihf_athlete(NULL)$player_name))
})
