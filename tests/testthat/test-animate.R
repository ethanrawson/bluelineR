test_that("animate_goal() writes a video", {
  skip_if_not_installed("av")
  skip_on_cran()
  file <- withr::local_tempfile(fileext = ".mp4")
  expect_identical(animate_goal(mcdavid_goal(), file, team = "EDM", fps = 5, slow_motion = FALSE,
                                width = 320, height = 180), file)
  info <- av::av_media_info(file)
  expect_equal(info$video$width, 320)
  expect_equal(info$video$height, 180)
  # 0.6 s held, the replay in real time, 0.5 s held.
  expect_equal(info$duration, 0.6 + max(mcdavid_goal()$time) + 0.5, tolerance = 0.5)
})

test_that("animate_goal() names the scorer and adds the slow motion", {
  skip_if_not_installed("av")
  skip_on_cran()
  local_nhl(c("ppt-replay" = "ppt-replay-2025020534-777"))
  goal <- nhl_goal_replay(2025020534, 777)
  fast <- withr::local_tempfile(fileext = ".mp4")
  slow <- withr::local_tempfile(fileext = ".mp4")
  animate_goal(mcdavid_goal(), fast, goal = goal, fps = 5, slow_motion = FALSE, width = 320, height = 180)
  animate_goal(mcdavid_goal(), slow, goal = goal, fps = 5, width = 320, height = 180)
  # Three seconds before the goal and 0.8 after at half speed, plus holds.
  expect_gt(av::av_media_info(slow)$duration - av::av_media_info(fast)$duration, 8)
})
