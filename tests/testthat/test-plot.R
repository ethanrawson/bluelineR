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
