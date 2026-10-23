#' Animate a goal as an MP4
#'
#' Writes a goal's tracking replay as a video: every skater, both goalies and
#' the puck on the rink, positions eased between the ten-a-second tracking
#' frames, each player's sweater number in his club's colors, the puck's
#' trail, the scorer ringed with his skating speed above him, the moment it
#' went in, and then the last three seconds again at half speed. The rink is
#' in feet from centre ice, as everywhere in bluelineR.
#'
#' Pass the goal from [nhl_goal_replay()] as `goal` to name the scorer and his
#' assists on the ice and title the video; without it the scorer is the
#' shooter [classify_goal()] finds and nobody is named.
#'
#' With `logos = TRUE` the clubs' logos stand in for their abbreviations in
#' the title and the home club's logo goes on centre ice; `centre_logo` puts
#' another there, like a special event's.
#'
#' Frames are drawn with base graphics and encoded by the av package (H.264
#' where FFmpeg has it); a full-size clip takes under a minute.
#'
#' @param frames Tracking frames from [nhl_goal_tracking()] or
#'   [read_goal_tracking()].
#' @param file Where to write the video (`.mp4`; `.gif` and `.webm` work too).
#' @param goal Optional: the goal from [nhl_goal_replay()].
#' @param team The scoring club, when `goal` is not given and it cannot be
#'   worked out from the frames (empty-net goals).
#' @param fps Frames per second.
#' @param slow_motion Replay the three seconds before the goal at half speed.
#' @param width,height Size in pixels.
#' @param title Title; `NULL` for the scorer, period and clock when `goal` is
#'   given.
#' @param logos Draw the clubs' logos (from `goal`, which has their
#'   addresses). Needs the rsvg package.
#' @param centre_logo The URL or path of a logo for centre ice, in place of the
#'   home club's: an SVG (needs rsvg) or a PNG (needs png).
#' @return `file`, invisibly.
#' @export
#' @examplesIf interactive() && requireNamespace("av", quietly = TRUE)
#' frames <- nhl_goal_tracking(2025020534, 777)
#' animate_goal(frames, "mcdavid.mp4", goal = nhl_goal_replay(2025020534, 777))
#'
#' # McDavid's overtime winner in the 4 Nations final, with the logos:
#' four_nations <- paste0("https://raw.githubusercontent.com/ethanrawson/bluelineR/Model/",
#'                        "man/figures/4-nations-logo.png")
#' animate_goal(nhl_goal_tracking(2024200007, 1443), "4-nations.mp4",
#'              goal = nhl_goal_replay(2024200007, 1443), logos = TRUE, centre_logo = four_nations)
#'
#' # Offline, from the copy that ships with the package:
#' path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
#' animate_goal(read_goal_tracking(path, 2025020534, 777), tempfile(fileext = ".mp4"), team = "EDM")
animate_goal <- function(frames, file = "goal.mp4", goal = NULL, team = NULL, fps = 30, slow_motion = TRUE,
                         width = 1280, height = 720, title = NULL, logos = FALSE, centre_logo = NULL) {
  rlang::check_installed("av", "to write the video")
  if (logos && is.null(goal)) cli::cli_abort("{.arg logos} needs the {.arg goal} from {.fn nhl_goal_replay}.")
  if (logos) rlang::check_installed("rsvg", "to draw the logos")
  frames <- frames[order(frames$frame), ]

  # Who to ring and name.
  scorer <- NA_real_; assists <- numeric(); names <- character()
  if (!is.null(goal)) {
    scorer <- as.numeric(goal$player_id[[1]])
    names[as.character(scorer)] <- goal$last_name[[1]] %||% ""
    a <- goal$assists[[1]]
    if (is.data.frame(a) && nrow(a)) {
      assists <- as.numeric(a$player_id)
      names[as.character(assists)] <- a$last_name %||% rep("", nrow(a))
    }
    team <- team %||% goal$team_abbrev[[1]]
    per <- goal$period[[1]]
    per <- switch(goal$period_type[[1]] %||% "REG", OT = if (per > 4) paste0(per - 3, "OT") else "OT", SO = "SO",
                  paste0("P", per))
    clock <- sprintf("%s %s", per, sub("^0", "", goal$time_in_period[[1]] %||% ""))
    who <- paste(goal$first_name[[1]] %||% "", goal$last_name[[1]] %||% "")
    away_logo <- if (logos) read_logo(goal$away_logo_dark[[1]] %||% NA)
    home_logo <- if (logos) read_logo(goal$home_logo_dark[[1]] %||% NA)
    if (is.null(title) && !is.null(away_logo) && !is.null(home_logo)) {
      title <- list(paste0(who, "  |  "), away_logo, sprintf(" %s-%s ", goal$away_score[[1]], goal$home_score[[1]]),
                    home_logo, paste0("  |  ", clock))
    }
    title <- title %||% sprintf("%s  |  %s %s-%s %s  |  %s", who, goal$away_team[[1]], goal$away_score[[1]],
                                goal$home_score[[1]], goal$home_team[[1]], clock)
  } else {
    cl <- classify_goal(frames, team = team)
    if (!is.null(cl)) { scorer <- cl$shooter; team <- team %||% cl$team }
  }
  title <- title %||% sprintf("Game %s, event %s", attr(frames, "game_id") %||% "", attr(frames, "event_id") %||% "")
  centre <- if (!is.null(centre_logo)) read_logo(centre_logo) else if (logos) read_logo(goal$home_logo[[1]] %||% NA)

  # The video's clock: replay seconds for each video frame.
  span <- max(frames$time)
  g <- goal_frame(frames)
  t_goal <- if (is.na(g)) NA_real_ else frames$time[frames$frame == g][[1]]
  step <- 1 / fps
  vt <- c(rep(0, round(0.6 * fps)), seq(0, span, by = step), rep(span, round(0.5 * fps)))
  slow <- rep(FALSE, length(vt))
  if (slow_motion && !is.na(t_goal)) {
    a <- max(0, t_goal - 3); b <- min(span, t_goal + 0.8)
    sm <- c(rep(a, round(0.3 * fps)), seq(a, b, by = step / 2), rep(b, round(1.2 * fps)))
    vt <- c(vt, sm)
    slow <- c(slow, rep(TRUE, length(sm)))
  }

  # Positions at every video time, eased between tracking frames: one
  # column per tracked object.
  ents <- frames[!duplicated(frames$entity_id), c("entity_id", "player_id", "sweater_number", "team", "is_puck")]
  at <- function(id, what) {
    f <- frames[frames$entity_id == id, ]
    if (nrow(f) < 2) return(rep(NA_real_, length(vt)))
    stats::approx(f$time, f[[what]], xout = vt, rule = 1, ties = mean)$y
  }
  X <- matrix(vapply(ents$entity_id, at, numeric(length(vt)), what = "x"), nrow = length(vt))
  Y <- matrix(vapply(ents$entity_id, at, numeric(length(vt)), what = "y"), nrow = length(vt))
  puck <- which(ents$is_puck)[1]

  # The scorer's speed for his badge.
  sp <- skater_speed(frames)
  sp <- sp[!is.na(sp$player_id) & sp$player_id %in% scorer & !is.na(sp$speed_mph), c("time", "speed_mph")]
  mph <- if (nrow(sp) > 1) stats::approx(sp$time, sp$speed_mph, xout = vt, rule = 2, ties = mean)$y else rep(NA_real_, length(vt))

  pal <- team_palette(sort(unique(stats::na.omit(ents$team))))
  k <- match(ents$team, pal$team)
  ents$fill <- pal$fill[k]; ents$stroke <- pal$stroke[k]; ents$text <- pal$text[k]

  draw <- function(i) {
    t <- vt[[i]]
    graphics::par(mar = c(0, 0, 0, 0), bg = "#0b1220")
    graphics::plot.new()
    graphics::plot.window(xlim = c(-101, 101), ylim = c(-55, 55), asp = 1)
    draw_rink_base()
    if (!is.null(centre)) place_logo(centre, 0, 0, 46, 24)
    # The puck's trail over the last 1.4 s.
    if (!is.na(puck)) {
      k <- which(vt <= t & vt >= t - 1.4 & seq_along(vt) <= i)
      graphics::lines(X[k, puck], Y[k, puck], col = grDevices::adjustcolor("#0b1220", 0.35), lwd = 2.2)
    }
    on <- which(!is.na(X[i, ]) & !ents$is_puck)
    named <- on[ents$player_id[on] %in% c(scorer, assists)]
    for (j in named) {
      graphics::points(X[i, j], Y[i, j], pch = 1, cex = 5.6, lwd = if (ents$player_id[j] %in% scorer) 4 else 3,
                       col = if (ents$player_id[j] %in% scorer) "#facc15" else "#93c5fd")
    }
    graphics::points(X[i, on], Y[i, on], pch = 21, cex = 4.1, bg = ents$fill[on], col = ents$stroke[on], lwd = 1.6)
    graphics::text(X[i, on], Y[i, on], ents$sweater_number[on], col = ents$text[on], font = 2, cex = 0.95)
    for (j in named) {
      lab <- names[as.character(ents$player_id[j])]
      if (!is.na(lab) && nzchar(lab)) halo_text(X[i, j], Y[i, j] + 4.6, lab, cex = 0.95)
    }
    # The scorer's speed until a second after the goal.
    sj <- on[ents$player_id[on] %in% scorer]
    if (length(sj) && !is.na(mph[i]) && (is.na(t_goal) || t < t_goal + 1)) {
      lab <- sprintf("%.1f MPH", mph[i])
      graphics::rect(X[i, sj] - 6.2, Y[i, sj] + 7, X[i, sj] + 6.2, Y[i, sj] + 11.4, col = "#0b1220", border = NA)
      graphics::text(X[i, sj], Y[i, sj] + 9.2, lab, col = "#facc15", font = 2, cex = 0.85)
    }
    if (!is.na(puck) && !is.na(X[i, puck])) {
      graphics::points(X[i, puck], Y[i, puck], pch = 21, cex = 1.7, bg = "#0b1220", col = "white", lwd = 1.2)
    }
    if (!is.na(t_goal) && t >= t_goal && t < t_goal + 1.8) {
      w <- graphics::strwidth("GOAL", cex = 5.5, font = 2) / 2 + 4
      h <- graphics::strheight("GOAL", cex = 5.5, font = 2) / 2 + 3
      graphics::rect(-w, -h, w, h, col = "#0b1220", border = "#ffd60a", lwd = 3)
      graphics::text(0, 0, "GOAL", col = "#ffd60a", font = 2, cex = 5.5)
    }
    draw_title(title, -99, 50.5, cex = 1.25)
    graphics::text(99, 50.5, sprintf("%.1f s", t), adj = c(1, 0.5), col = "white", font = 2, cex = 1.1)
    if (slow[[i]]) graphics::text(0, -50.5, "SLOW MOTION  1/2x", col = "#ffd60a", font = 2, cex = 1.1)
    graphics::text(-99, -50.5, "NHL puck and player tracking", adj = c(0, 0.5), col = "#fde68a", cex = 0.9)
    graphics::text(99, -50.5, "bluelineR", adj = c(1, 0.5), col = "white", font = 2, cex = 0.9)
  }

  av::av_capture_graphics(for (i in seq_along(vt)) draw(i), output = file, width = width, height = height,
                          res = 110 * width / 1280, framerate = fps, verbose = FALSE)
  invisible(file)
}

# A logo as a raster, from the URL or path of an SVG or PNG; NULL when there
# is none.
read_logo <- function(src, height = 400) {
  if (is.null(src) || is.na(src) || !nzchar(src)) return(NULL)
  data <- if (grepl("^https?://", src)) fetch_raw(src) else readBin(src, "raw", file.size(src))
  img <- if (identical(data[2:4], charToRaw("PNG"))) {
    rlang::check_installed("png", "to read a PNG logo")
    png::readPNG(data, native = TRUE)
  } else {
    rlang::check_installed("rsvg", "to read an SVG logo")
    rsvg::rsvg_nativeraster(data, height = height)
  }
  # Trim the transparent margin, so logos sit as close as text does. A
  # nativeRaster holds its pixels row by row.
  px <- matrix(as.integer(img), nrow(img), ncol(img), byrow = TRUE)
  seen <- matrix(bitwShiftR(px, 24L) > 0L, nrow(px))
  rows <- range(which(rowSums(seen) > 0)); cols <- range(which(colSums(seen) > 0))
  px <- px[rows[1]:rows[2], cols[1]:cols[2], drop = FALSE]
  structure(as.vector(t(px)), dim = dim(px), class = "nativeRaster", channels = 4L)
}

# Fit a logo in a max_w by max_h box (feet) centred on (x, y).
place_logo <- function(img, x, y, max_w, max_h) {
  k <- min(max_w / ncol(img), max_h / nrow(img))
  w <- ncol(img) * k / 2; h <- nrow(img) * k / 2
  graphics::rasterImage(img, x - w, y - h, x + w, y + h, interpolate = TRUE)
}

# A title of text and logos, left to right from (x, y).
draw_title <- function(parts, x, y, cex) {
  h <- 2.4 * graphics::strheight("M", cex = cex, font = 2)
  for (p in if (is.list(parts)) parts else list(parts)) {
    if (is.character(p)) {
      graphics::text(x, y, p, adj = c(0, 0.5), col = "white", font = 2, cex = cex)
      x <- x + graphics::strwidth(p, cex = cex, font = 2)
    } else {
      w <- h * ncol(p) / nrow(p)
      graphics::rasterImage(p, x, y - h / 2, x + w, y + h / 2, interpolate = TRUE)
      x <- x + w
    }
  }
}

halo_text <- function(x, y, label, cex = 1, col = "#0b1220", halo = "#f7f9fc", r = 0.45) {
  for (a in seq(0, 2 * pi, length.out = 13)[-13]) {
    graphics::text(x + r * cos(a), y + r * sin(a), label, col = halo, font = 2, cex = cex)
  }
  graphics::text(x, y, label, col = col, font = 2, cex = cex)
}

# The rink in base graphics, in feet from centre ice (as nhl_rink(), faster
# for drawing hundreds of video frames).
draw_rink_base <- function(ice = "#f7f9fc") {
  arc <- function(cx, cy, r, from, to, n = 60) { a <- seq(from, to, length.out = n); cbind(cx + r * cos(a), cy + r * sin(a)) }
  boards <- rbind(arc(72, 14.5, 28, 0, pi / 2), arc(-72, 14.5, 28, pi / 2, pi),
                  arc(-72, -14.5, 28, pi, 3 * pi / 2), arc(72, -14.5, 28, 3 * pi / 2, 2 * pi))
  graphics::polygon(boards, col = ice, border = NA)
  red <- "#c8102e"; blue <- "#0033a0"
  goal_y <- 14.5 + sqrt(28^2 - (89 - 72)^2)
  for (s in c(-1, 1)) {
    crease <- if (s > 0) arc(89, 0, 6, pi / 2, 3 * pi / 2) else arc(-89, 0, 6, -pi / 2, pi / 2)
    graphics::polygon(crease, col = "#cfe4f7", border = red, lwd = 1)
    graphics::segments(89 * s, -goal_y, 89 * s, goal_y, col = red, lwd = 1.6)
    graphics::segments(25 * s, -42.5, 25 * s, 42.5, col = blue, lwd = 5)
    graphics::polygon(s * c(89, 92.3, 92.3, 89), c(-3, -2.5, 2.5, 3), col = "white", border = red, lwd = 1.2)
    for (y in c(-22, 22)) {
      graphics::polygon(arc(69 * s, y, 15, 0, 2 * pi, 120), border = red, lwd = 1.1)
      graphics::polygon(arc(69 * s, y, 1, 0, 2 * pi, 30), col = red, border = NA)
      graphics::polygon(arc(20 * s, y, 1, 0, 2 * pi, 30), col = red, border = NA)
    }
  }
  graphics::segments(0, -42.5, 0, 42.5, col = red, lwd = 5, lty = "22")
  graphics::polygon(arc(0, 0, 15, 0, 2 * pi, 120), border = blue, lwd = 1.1)
  graphics::polygon(boards, border = "#8a97ab", lwd = 2.4)
}
