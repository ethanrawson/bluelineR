test_that("plots build", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(nhl_rink(), "ggplot")
  fr <- mcdavid_goal()
  p <- plot_goal(fr, title = "McDavid")
  expect_s3_class(p, "ggplot")
  expect_silent(ggplot2::ggplot_build(p))
  expect_s3_class(plot_goal_sequence(fr), "ggplot")
  local_nhl(c("play-by-play" = "pbp-2025020534"))
  expect_s3_class(plot_shots(nhl_pbp(2025020534)), "ggplot")
})

test_that("national teams get their own colors", {
  pal <- team_palette(c("CAN", "USA"))
  expect_equal(pal$fill, c("#D80621", "#041E42"))
  expect_equal(team_palette(c("EDM", "XYZ"))$fill, c("#041E42", "#1f6feb"))
})

test_that("plot_shots() puts each club at its own end", {
  skip_if_not_installed("ggplot2")
  local_nhl(c("play-by-play" = "pbp-2025020534"))
  pbp <- nhl_pbp(2025020534)
  p <- plot_shots(pbp)
  d <- p$layers[[length(p$layers)]]$data
  # The away club's shots at the left net, the home club's at the right.
  expect_true(stats::median(d$x_plot[d$event_team_type == "away"]) < 0)
  expect_true(stats::median(d$x_plot[d$event_team_type == "home"]) > 0)
  one <- plot_shots(pbp, sides = "right")
  d1 <- one$layers[[length(one$layers)]]$data
  expect_true(stats::median(d1$x_plot) > 0)
  expect_true(stats::median(d1$x_plot[d1$event_team_type == "away"]) > 0)
})

test_that("plot_shots() draws an IIHF game at both ends too", {
  skip_if_not_installed("ggplot2")
  local_nhl(c("GetLatestState/1010000058" = "iihf-1010000058"))
  p <- plot_shots(iihf_shots(1010000058))
  d <- p$layers[[length(p$layers)]]$data
  expect_true(stats::median(d$x_plot[d$team_side == "away"]) < 0)
  expect_true(stats::median(d$x_plot[d$team_side == "home"]) > 0)
  expect_match(p$labels$title, "USA at the left net, CAN at the right")
})
