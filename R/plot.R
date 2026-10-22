#' Draw an NHL rink
#'
#' A ggplot2 rink in feet from centre ice, x along the rink (-100 to 100)
#' and y across it (-42.5 to 42.5), the frame the play-by-play and the
#' tracking use. Add layers to it like any ggplot.
#'
#' @param ice Fill for the ice.
#' @return A ggplot.
#' @export
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) nhl_rink()
nhl_rink <- function(ice = "#f7f9fc") {
  rlang::check_installed("ggplot2", "to draw a rink")
  arc <- function(cx, cy, r, from, to, n = 60) {
    a <- seq(from, to, length.out = n)
    data.frame(x = cx + r * cos(a), y = cy + r * sin(a))
  }
  circle <- function(cx, cy, r) arc(cx, cy, r, 0, 2 * pi, 120)
  boards <- rbind(
    arc(72, 14.5, 28, 0, pi / 2), arc(-72, 14.5, 28, pi / 2, pi),
    arc(-72, -14.5, 28, pi, 3 * pi / 2), arc(72, -14.5, 28, 3 * pi / 2, 2 * pi)
  )
  boards <- rbind(boards, boards[1, ])
  goal_y <- 14.5 + sqrt(28^2 - (89 - 72)^2)
  red <- "#c8102e"; blue <- "#0033a0"
  path <- function(d, colour, linewidth = 0.5, ...) {
    ggplot2::geom_path(data = d, ggplot2::aes(.data$x, .data$y), colour = colour, linewidth = linewidth, inherit.aes = FALSE, ...)
  }
  poly <- function(d, fill, colour = NA, ...) {
    ggplot2::geom_polygon(data = d, ggplot2::aes(.data$x, .data$y), fill = fill, colour = colour, inherit.aes = FALSE, ...)
  }
  layers <- list(poly(boards, ice))
  for (s in c(-1, 1)) {
    crease <- if (s > 0) arc(89, 0, 6, pi / 2, 3 * pi / 2) else arc(-89, 0, 6, -pi / 2, pi / 2)
    net <- data.frame(x = s * c(89, 92.3, 92.3, 89), y = c(-3, -2.5, 2.5, 3))
    layers <- c(layers, list(
      poly(crease, "#cfe4f7", red, linewidth = 0.3),
      path(data.frame(x = 89 * s, y = c(-goal_y, goal_y)), red, 0.5),
      path(data.frame(x = 25 * s, y = c(-42.5, 42.5)), blue, 1.4),
      poly(net, "#ffffff", red, linewidth = 0.4),
      path(circle(69 * s, 22, 15), red, 0.35), path(circle(69 * s, -22, 15), red, 0.35),
      poly(circle(69 * s, 22, 1), red), poly(circle(69 * s, -22, 1), red),
      poly(circle(20 * s, 22, 1), red), poly(circle(20 * s, -22, 1), red)
    ))
  }
  layers <- c(layers, list(
    path(data.frame(x = 0, y = c(-42.5, 42.5)), red, 1.4, linetype = "22"),
    path(circle(0, 0, 15), blue, 0.35), poly(circle(0, 0, 0.6), blue),
    path(boards, "#8a97ab", 0.8)
  ))
  ggplot2::ggplot() + layers + ggplot2::coord_fixed(xlim = c(-101, 101), ylim = c(-43.5, 43.5), expand = FALSE) +
    ggplot2::theme_void() + ggplot2::theme(plot.background = ggplot2::element_rect(fill = "white", colour = NA))
}

team_palette <- function(teams) {
  info <- nhl_team_info()
  fill <- info$primary_color[match(teams, info$abbrev)]
  # National teams: the 4 Nations Face-Off, whose goals are tracked too, and
  # the IIHF's tournaments (iihf_shots()).
  nations <- c(CAN = "#D80621", USA = "#041E42", SWE = "#005293", FIN = "#002F6C", CZE = "#11457E", SUI = "#DA291C",
               GER = "#1a1a1a", SVK = "#0B4EA2", LAT = "#9E3039", DEN = "#C8102E", NOR = "#BA0C2F", AUT = "#ED2939",
               FRA = "#0055A4", KAZ = "#00AFCA", ITA = "#008C45", GBR = "#012169", HUN = "#477050", SLO = "#005DA4",
               POL = "#DC143C", JPN = "#BC002D", KOR = "#003478", CHN = "#DE2910", UKR = "#0057B7", NED = "#AE1C28",
               BLR = "#C8313E", RUS = "#0039A6", EST = "#0072CE", LTU = "#006A44", ROU = "#002B7F", CRO = "#171796")
  fill[is.na(fill)] <- unname(nations[teams[is.na(fill)]])
  fill[is.na(fill)] <- c("#1f6feb", "#64748b")[seq_len(sum(is.na(fill)))]
  # Two clubs in alike colors: the second goes white with its color outlined.
  rgb <- grDevices::col2rgb(fill)
  hollow <- length(fill) == 2 && sqrt(sum((rgb[, 1] - rgb[, 2])^2)) < 120
  text <- ifelse(colSums(rgb * c(0.299, 0.587, 0.114)) / 255 > 0.62, "#0b1220", "#ffffff")
  out <- data.frame(team = teams, fill = fill, stroke = "#ffffff", text = text, stringsAsFactors = FALSE)
  if (hollow) { out$stroke[2] <- out$fill[2]; out$fill[2] <- "#ffffff"; out$text[2] <- "#0b1220" }
  out
}

#' Plot a goal from its tracking
#'
#' `plot_goal()` draws every skater, both goalies and the puck at one frame
#' (by default the moment it went in), each with the path he skated over the
#' `trail` seconds before, and the puck's path. `plot_goal_sequence()` draws
#' `n` frames leading up to the goal, side by side.
#'
#' @param frames Tracking frames from [nhl_goal_tracking()].
#' @param frame The frame to draw; `NULL` for the goal ([goal_frame()]).
#' @param trail Seconds of path behind each player and the puck.
#' @param title Plot title; `NULL` for the game and event ids.
#' @return A ggplot.
#' @export
#' @examples
#' path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
#' frames <- read_goal_tracking(path, 2025020534, 777)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   plot_goal(frames, title = "McDavid, shorthanded breakaway at Boston")
#' }
plot_goal <- function(frames, frame = NULL, trail = 2, title = NULL) {
  rlang::check_installed("ggplot2", "to plot a goal")
  frame <- frame %||% goal_frame(frames)
  if (is.na(frame)) frame <- max(frames$frame)
  now <- frames[frames$frame == frame, ]
  t_now <- now$time[[1]]
  past <- frames[frames$time <= t_now & frames$time >= t_now - trail, ]
  past <- past[order(past$entity_id, past$frame), ]
  teams <- sort(unique(stats::na.omit(frames$team)))
  pal <- team_palette(teams)
  people <- now[!now$is_puck, ]
  people <- merge(people, pal, by = "team", all.x = TRUE)
  puck_now <- now[now$is_puck, ]
  title <- title %||% sprintf("Game %s, event %s", attr(frames, "game_id") %||% "", attr(frames, "event_id") %||% "")

  nhl_rink() +
    ggplot2::geom_path(data = past[!past$is_puck, ], ggplot2::aes(.data$x, .data$y, group = .data$entity_id, colour = .data$team),
                       linewidth = 0.5, alpha = 0.45) +
    ggplot2::geom_path(data = past[past$is_puck, ], ggplot2::aes(.data$x, .data$y), colour = "#0b1220", linewidth = 0.6, alpha = 0.7) +
    ggplot2::geom_point(data = people, ggplot2::aes(.data$x, .data$y, fill = .data$team), shape = 21, size = 6.2,
                        colour = people$stroke, stroke = 0.8) +
    ggplot2::geom_text(data = people, ggplot2::aes(.data$x, .data$y, label = .data$sweater_number),
                       colour = people$text, size = 2.6, fontface = "bold") +
    ggplot2::geom_point(data = puck_now, ggplot2::aes(.data$x, .data$y), shape = 21, size = 2.4, fill = "#0b1220", colour = "white") +
    ggplot2::scale_fill_manual(values = stats::setNames(pal$fill, pal$team), name = NULL) +
    ggplot2::scale_colour_manual(values = stats::setNames(ifelse(pal$fill == "#ffffff", pal$stroke, pal$fill), pal$team), guide = "none") +
    ggplot2::labs(title = title, subtitle = sprintf("%.1f s into the clip; lines are the last %g s", t_now, trail),
                  caption = "NHL puck and player tracking") +
    ggplot2::theme(legend.position = "bottom", plot.margin = ggplot2::margin(6, 6, 6, 6))
}

#' @rdname plot_goal
#' @param n Number of frames.
#' @param seconds How far before the goal the sequence starts.
#' @export
plot_goal_sequence <- function(frames, n = 6, seconds = 5, title = NULL) {
  rlang::check_installed("ggplot2", "to plot a goal")
  g <- goal_frame(frames)
  if (is.na(g)) g <- max(frames$frame)
  t_goal <- frames$time[frames$frame == g][[1]]
  times <- seq(max(0, t_goal - seconds), t_goal, length.out = n)
  pick <- vapply(times, function(t) frames$frame[which.min(abs(frames$time - t))], numeric(1))
  snap <- frames[frames$frame %in% pick, ]
  snap$panel <- factor(sprintf("%.1f s before the goal", t_goal - snap$time),
                       levels = unique(sprintf("%.1f s before the goal", t_goal - frames$time[match(pick, frames$frame)])))
  pal <- team_palette(sort(unique(stats::na.omit(frames$team))))
  people <- merge(snap[!snap$is_puck, ], pal, by = "team", all.x = TRUE)
  nhl_rink() +
    ggplot2::geom_point(data = people, ggplot2::aes(.data$x, .data$y, fill = .data$team), shape = 21, size = 2.6, colour = people$stroke) +
    ggplot2::geom_point(data = snap[snap$is_puck, ], ggplot2::aes(.data$x, .data$y), size = 1.4, colour = "#0b1220") +
    ggplot2::scale_fill_manual(values = stats::setNames(pal$fill, pal$team), name = NULL) +
    ggplot2::facet_wrap(~panel, ncol = 2) +
    ggplot2::labs(title = title %||% sprintf("Game %s, event %s", attr(frames, "game_id") %||% "", attr(frames, "event_id") %||% "")) +
    ggplot2::theme(legend.position = "bottom", strip.text = ggplot2::element_text(margin = ggplot2::margin(4, 0, 4, 0)))
}

#' Shot map
#'
#' A game's shots on the rink, every club attacking to the right
#' (`x_fixed`, `y_fixed` from [nhl_pbp()]): goals, saves and misses.
#'
#' @param pbp Play-by-play from [nhl_pbp()], or an IIHF game's shots from
#'   [iihf_shots()].
#' @param team Only this club's shots; `NULL` for both, coloured by club.
#' @return A ggplot.
#' @export
#' @examplesIf interactive()
#' plot_shots(nhl_pbp(2025020534))
plot_shots <- function(pbp, team = NULL) {
  rlang::check_installed("ggplot2", "to plot shots")
  shots <- pbp[pbp$type %in% c("goal", "shot-on-goal", "missed-shot") & !is.na(pbp$x_fixed), ]
  if (!is.null(team)) shots <- shots[shots$event_team == team, ]
  shots$result <- factor(c(goal = "Goal", `shot-on-goal` = "Saved", `missed-shot` = "Missed")[shots$type],
                         levels = c("Goal", "Saved", "Missed"))
  pal <- team_palette(sort(unique(shots$event_team)))
  nhl_rink() +
    ggplot2::geom_point(data = shots, ggplot2::aes(.data$x_fixed, .data$y_fixed, shape = .data$result, size = .data$result,
                                                   colour = .data$event_team), stroke = 1.1) +
    ggplot2::scale_shape_manual(values = c(Goal = 16, Saved = 1, Missed = 4), name = NULL, drop = FALSE) +
    ggplot2::scale_size_manual(values = c(Goal = 4, Saved = 2.4, Missed = 2), name = NULL, drop = FALSE) +
    ggplot2::scale_colour_manual(values = stats::setNames(ifelse(pal$fill == "#ffffff", pal$stroke, pal$fill), pal$team), name = NULL) +
    ggplot2::labs(title = "Shots, attacking right",
                  caption = if (identical(attr(pbp, "source"), "IIHF")) "IIHF live data" else "NHL play-by-play") +
    ggplot2::theme(legend.position = "bottom")
}
