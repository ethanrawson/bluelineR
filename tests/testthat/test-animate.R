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

# A 40 by 20 logo: a 20 by 10 red block in a transparent margin.
logo_svg <- function() {
  charToRaw(paste0('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="20">',
                   '<rect x="10" y="5" width="20" height="10" fill="#d80621"/></svg>'))
}

test_that("logos are read from SVG or PNG and trimmed", {
  skip_if_not_installed("rsvg")
  skip_if_not_installed("png")
  svg <- withr::local_tempfile(fileext = ".svg")
  writeBin(logo_svg(), svg)
  img <- read_logo(svg, height = 20)
  expect_s3_class(img, "nativeRaster")
  expect_equal(dim(img), c(10, 20))
  png_file <- withr::local_tempfile(fileext = ".png")
  png::writePNG(rsvg::rsvg_nativeraster(logo_svg(), height = 20), png_file)
  expect_equal(dim(read_logo(png_file)), c(10, 20))
  expect_null(read_logo(NA))
})

test_that("animate_goal() draws the logos", {
  skip_if_not_installed("av")
  skip_if_not_installed("rsvg")
  skip_on_cran()
  local_nhl(c("ppt-replay" = "ppt-replay-2025020534-777"))
  fetched <- character()
  local_mocked_bindings(fetch_raw = function(url) { fetched <<- c(fetched, url); logo_svg() })
  goal <- nhl_goal_replay(2025020534, 777)
  file <- withr::local_tempfile(fileext = ".mp4")
  animate_goal(mcdavid_goal(), file, goal = goal, logos = TRUE, fps = 5, slow_motion = FALSE, width = 320, height = 180)
  expect_true(file.exists(file))
  expect_setequal(fetched, c(goal$away_logo_dark, goal$home_logo_dark, goal$home_logo))
  expect_error(animate_goal(mcdavid_goal(), file, logos = TRUE), "goal")
})
