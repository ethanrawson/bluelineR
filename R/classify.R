#' How a goal was scored, from its tracking
#'
#' Reads a goal's tracking frames the way BluelineMetrics' goal types are
#' built (bluelinemetrics.com): who released it, from how far and how hard,
#' and whether it came off the rush, on a breakaway or an odd-man rush, as a
#' one-timer, across the slot, through traffic, from behind the net or off
#' the forecheck. Who did what is by NHL player id.
#'
#' A skater has the puck when he is the nearest one within 4 feet of it for
#' two frames running. The frames are turned so the scoring team attacks the
#' net at x = +89.
#'
#' * `rush`: the puck was on the far side of centre ice within 5 seconds of
#'   the release (`since`, seconds).
#' * `breakaway`: a rush the shooter carried over the blue line with no
#'   defender but the goalie between him and the net from there to the shot.
#' * `oddman`: a rush with two or three attackers level with the puck or
#'   ahead at the blue line and more of them than defenders back.
#' * `onetimer`: shot within 0.3 s of a teammate's pass, from more than 12 ft
#'   (tips and deflections aside); `otpass` is the passer.
#' * `cross`: the puck crossed the slot (from one side to the other, 12+ ft)
#'   in the 2 seconds before the release; `xpass` made the pass.
#' * `traffic`: a skater other than the goalie in the triangle from the
#'   release to the posts; `screens` are teammates in the shooting lane.
#' * `behind`: the pass in came from behind the goal line, within 30 ft;
#'   `bnpass` made it.
#' * `forecheck`: the other side's last possession, 0.5+ s, was in this zone
#'   within 5 s of the release and the puck never left the zone; `fcwin` is
#'   the teammate who won it back.
#' * `speed`: shot speed (mph), the puck's fastest move in the 0.3 s after
#'   the release. `passes`: passes since the team last won the puck.
#'
#' @param frames Tracking frames from [nhl_goal_tracking()].
#' @param team The scoring club's abbreviation. Worked out from the frames
#'   when `NULL` (the club attacking the net the puck ends in), which needs a
#'   goalie in that net: pass it for empty-net goals.
#' @param goalie_ids NHL player ids of the goalies. When `NULL`, each club's
#'   goalie is the skater who spends the clip closest to its net.
#' @param shot_type The play-by-play's shot type (`"tip-in"` and
#'   `"deflected"` are never one-timers).
#' @return A one-row tibble, or `NULL` when the frames do not show the goal.
#' @export
#' @examples
#' path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
#' frames <- read_goal_tracking(path, 2025020534, 777)
#' classify_goal(frames, team = "EDM", shot_type = "backhand")
classify_goal <- function(frames, team = NULL, goalie_ids = NULL, shot_type = "") {
  frames <- frames[order(frames$frame), ]
  ids <- sort(unique(frames$frame))
  Fr <- lapply(split(frames, factor(frames$frame, levels = ids)), function(f) {
    list(t = round(f$time[[1]] * 10), ent = f$entity_id, tm = f$team, x = f$x, y = f$y, pid = f$player_id)
  })
  n <- length(Fr)
  pid_of <- stats::setNames(frames$player_id, frames$entity_id)
  pid_of <- pid_of[!duplicated(names(pid_of)) & !is.na(pid_of)]
  pid <- function(id) if (is.null(id) || is.na(id)) NA_real_ else unname(pid_of[as.character(id)])

  puck <- function(i) { f <- Fr[[i]]; k <- which(f$ent == 1); if (length(k)) c(f$x[[k[1]]], f$y[[k[1]]]) else NULL }
  pos <- function(i, id) { f <- Fr[[i]]; k <- which(f$ent == id); if (length(k)) c(f$x[[k[1]]], f$y[[k[1]]]) else NULL }
  team_at <- function(i, id) { f <- Fr[[i]]; k <- which(f$ent == id); if (length(k)) f$tm[[k[1]]] else NA_character_ }
  dist2 <- function(a, b) sqrt((a[1] - b[1])^2 + (a[2] - b[2])^2)

  # Turn the frames so the net it finishes in is at x = +89.
  last_p <- NULL
  for (i in rev(seq_len(n))) { last_p <- puck(i); if (!is.null(last_p)) break }
  if (is.null(last_p)) return(NULL)
  if (last_p[1] < 0) Fr <- lapply(Fr, function(f) { f$x <- -f$x; f$y <- -f$y; f })

  # Goalies: given, or each club's skater who spends the clip closest to its net.
  teams <- unique(stats::na.omit(frames$team))
  sk <- frames[!frames$is_puck & !is.na(frames$team), ]
  sk$x <- if (last_p[1] < 0) -sk$x else sk$x
  sk$y <- if (last_p[1] < 0) -sk$y else sk$y
  near <- function(net_x) {
    d <- sqrt((sk$x - net_x)^2 + sk$y^2)
    m <- tapply(d, sk$entity_id, stats::median)
    m
  }
  if (is.null(team)) {
    m <- near(89)
    defending <- sk$team[match(as.numeric(names(m)[which.min(m)]), sk$entity_id)]
    team <- setdiff(teams, defending)[1]
    if (is.na(team)) return(NULL)
  }
  goalie_ents <- if (!is.null(goalie_ids)) {
    unique(frames$entity_id[!is.na(frames$player_id) & frames$player_id %in% goalie_ids])
  } else {
    m_def <- near(89); m_att <- near(-89)
    ent_team <- stats::setNames(sk$team, sk$entity_id)
    def_ids <- names(m_def)[ent_team[names(m_def)] != team]
    att_ids <- names(m_att)[ent_team[names(m_att)] == team]
    as.numeric(c(def_ids[which.min(m_def[def_ids])], att_ids[which.min(m_att[att_ids])]))
  }
  is_g <- function(id) id %in% goalie_ents

  # The goal: the first time the puck is in the net for two frames running.
  in_net <- function(i) { if (i > n) return(FALSE); q <- puck(i); !is.null(q) && q[1] >= 89 && q[1] <= 92.6 && abs(q[2]) <= 3.2 }
  gi <- NA
  for (i in seq_len(n)) if (in_net(i) && in_net(i + 1)) { gi <- i; break }
  if (is.na(gi)) for (i in seq_len(n)) if (in_net(i)) { gi <- i; break }
  if (is.na(gi) || gi <= 1) return(NULL)

  # The release: the last frame before it a teammate was within 4 ft of the puck.
  rel <- NA; shooter <- NA
  for (i in (gi - 1):1) {
    q <- puck(i); if (is.null(q)) next
    f <- Fr[[i]]
    for (k in seq_along(f$ent)) {
      if (f$ent[[k]] == 1 || is.na(f$tm[[k]]) || f$tm[[k]] != team) next
      if (dist2(c(f$x[[k]], f$y[[k]]), q) < 4) { rel <- i; shooter <- f$ent[[k]]; break }
    }
    if (!is.na(rel)) break
  }
  if (is.na(rel)) return(NULL)
  rp <- puck(rel)
  t_rel <- Fr[[rel]]$t

  since <- NA_real_
  for (i in rel:1) {
    if (t_rel - Fr[[i]]$t > 150) break
    q <- puck(i); if (!is.null(q) && q[1] < 0) { since <- (t_rel - Fr[[i]]$t) / 10; break }
  }
  rush <- !is.na(since) && since <= 5

  min_y <- 99; max_y <- -99
  for (i in rel:1) {
    if (t_rel - Fr[[i]]$t > 20) break
    q <- puck(i); if (!is.null(q) && q[1] > 54) { min_y <- min(min_y, q[2]); max_y <- max(max_y, q[2]) }
  }
  cross <- min_y < -4 && max_y > 4 && max_y - min_y >= 12

  to_line <- function(p, a, b) {
    dx <- b[1] - a[1]; dy <- b[2] - a[2]
    t <- ((p[1] - a[1]) * dx + (p[2] - a[2]) * dy) / (dx * dx + dy * dy)
    if (t <= 0 || t > 1) Inf else sqrt((p[1] - a[1] - t * dx)^2 + (p[2] - a[2] - t * dy)^2)
  }
  in_tri <- function(p, a, b, c) {
    s <- function(p1, p2, p3) (p1[1] - p3[1]) * (p2[2] - p3[2]) - (p2[1] - p3[1]) * (p1[2] - p3[2])
    d1 <- s(p, a, b); d2 <- s(p, b, c); d3 <- s(p, c, a)
    !((d1 < 0 || d2 < 0 || d3 < 0) && (d1 > 0 || d2 > 0 || d3 > 0))
  }
  traffic <- 0; screens <- numeric()
  f <- Fr[[rel]]
  for (k in seq_along(f$ent)) {
    id <- f$ent[[k]]
    if (id == 1 || id == shooter) next
    p <- c(f$x[[k]], f$y[[k]])
    if (!is.na(f$tm[[k]]) && f$tm[[k]] == team && p[1] <= 89 && dist2(p, rp) >= 3 &&
        to_line(p, rp, c(89, 0)) <= 3.5 && !is.na(pid(id))) screens <- c(screens, pid(id))
    if (dist2(p, c(89, 0)) < 2.5) next
    if (in_tri(p, rp, c(89, -3), c(89, 3))) traffic <- traffic + 1
  }

  # Possession runs over the 15 seconds before the release.
  runs <- list()
  for (i in seq_len(rel)) {
    if (t_rel - Fr[[i]]$t > 150) next
    q <- puck(i); if (is.null(q)) next
    f <- Fr[[i]]
    best <- NA; bd <- 4
    for (k in seq_along(f$ent)) {
      if (f$ent[[k]] == 1) next
      d <- dist2(c(f$x[[k]], f$y[[k]]), q)
      if (d < bd) { bd <- d; best <- f$ent[[k]] }
    }
    if (is.na(best)) next
    r <- if (length(runs)) runs[[length(runs)]] else NULL
    if (!is.null(r) && r$id == best && r$end == i - 1) {
      runs[[length(runs)]]$end <- i
      runs[[length(runs)]]$n <- r$n + 1
    } else {
      runs[[length(runs) + 1]] <- list(id = best, start = i, end = i, n = 1)
    }
  }
  held <- Filter(function(r) r$n >= 2 || r$id == shooter, runs)
  last_which <- function(pred) { w <- which(vapply(held, pred, logical(1))); if (length(w)) max(w) else NA }
  mine <- function(r) identical(team_at(r$start, r$id), team)

  xpass <- NA_real_
  if (cross) {
    k <- last_which(function(r) r$id != shooter && r$start < rel)
    if (!is.na(k)) {
      r <- held[[k]]
      after <- if (k < length(held)) held[(k + 1):length(held)] else list()
      if (identical(team_at(r$end, r$id), team) && all(vapply(after, function(h) h$id == shooter, logical(1))) &&
          t_rel - Fr[[r$end]]$t <= 25) {
        q <- puck(r$end)
        if (!is.null(q) && abs(q[2]) >= 2 && abs(rp[2]) >= 2 && sign(q[2]) != sign(rp[2])) xpass <- pid(r$id)
      }
    }
  }

  carrier <- NA_real_
  if (rush && rel >= 2) {
    for (i in rel:2) {
      q <- puck(i); q0 <- puck(i - 1)
      if (is.null(q) || is.null(q0) || !(q0[1] < 25 && q[1] >= 25)) next
      best <- NA; bd <- 5
      for (j in max(1, i - 2):min(rel, i + 2)) {
        pq <- puck(j); if (is.null(pq)) next
        f <- Fr[[j]]
        for (k in seq_along(f$ent)) {
          if (f$ent[[k]] == 1 || is.na(f$tm[[k]]) || f$tm[[k]] != team) next
          d <- dist2(c(f$x[[k]], f$y[[k]]), pq)
          if (d < bd) { bd <- d; best <- f$ent[[k]] }
        }
      }
      carrier <- pid(best)
      break
    }
  }

  bl <- NA
  if (rel >= 2) for (i in rel:2) {
    q <- puck(i); q0 <- puck(i - 1)
    if (!is.null(q) && !is.null(q0) && q0[1] < 25 && q[1] >= 25) { bl <- i; break }
  }
  breakaway <- FALSE; oddman <- FALSE
  if (rush && !is.na(bl)) {
    q <- puck(bl); f <- Fr[[bl]]
    bl_carrier <- NA; bd <- 6; att <- 0; def <- 0
    for (k in seq_along(f$ent)) {
      id <- f$ent[[k]]
      if (id == 1 || is_g(id) || is.na(f$tm[[k]])) next
      p <- c(f$x[[k]], f$y[[k]])
      d <- dist2(p, q)
      if (f$tm[[k]] == team && d < bd) { bd <- d; bl_carrier <- id }
      if (f$tm[[k]] == team && p[1] >= q[1] - 12) att <- att + 1
      if (f$tm[[k]] != team && p[1] >= q[1] - 3) def <- def + 1
    }
    ahead <- 0
    for (i in bl:rel) {
      pq <- puck(i); if (is.null(pq)) next
      f <- Fr[[i]]
      m <- sum(vapply(seq_along(f$ent), function(k) {
        id <- f$ent[[k]]
        id != 1 && !is.na(f$tm[[k]]) && f$tm[[k]] != team && !is_g(id) && f$x[[k]] > pq[1] + 1
      }, logical(1)))
      ahead <- max(ahead, m)
    }
    breakaway <- ahead == 0 && identical(bl_carrier, shooter)
    oddman <- !breakaway && att > def && att >= 2 && att <= 3
  }

  dist <- sqrt((89 - rp[1])^2 + rp[2]^2)
  k <- last_which(function(r) r$id == shooter && r$start <= rel)
  prev <- if (!is.na(k) && k > 1) held[[k - 1]] else NULL
  passer <- if (!is.na(k) && !is.null(prev) && mine(prev) && prev$id != shooter && held[[k]]$start - prev$end <= 15) prev else NULL
  onetimer <- !is.null(passer) && (rel - held[[k]]$start + 1) <= 3 && dist > 12 && !grepl("tip|deflect", shot_type)
  behind <- !is.null(passer) && dist <= 30 && isTRUE(puck(passer$end)[1] > 89)

  ti <- last_which(function(r) !mine(r) && !is_g(r$id) && r$end < rel)
  forecheck <- FALSE; fcwin <- NA_real_
  if (!is.na(ti) && held[[ti]]$n >= 5 && t_rel - Fr[[held[[ti]]$end]]$t <= 50 &&
      isTRUE((puck(held[[ti]]$end) %||% c(0, 0))[1] >= 25)) {
    forecheck <- TRUE
    for (i in held[[ti]]$end:rel) { p <- puck(i); if (!is.null(p) && p[1] < 25) { forecheck <- FALSE; break } }
    after <- if (ti < length(held)) held[(ti + 1):length(held)] else list()
    w <- Filter(mine, after)
    if (forecheck && length(w)) fcwin <- pid(w[[1]]$id)
  }

  speed <- 0
  last_i <- min(gi, rel + 3) - 1
  if (last_i >= rel) for (i in rel:last_i) {
    a <- puck(i); b <- if (i + 1 <= n) puck(i + 1) else NULL
    if (!is.null(a) && !is.null(b)) speed <- max(speed, dist2(a, b) * 10 * 0.681818)
  }

  start <- if (is.na(ti)) 1 else ti + 1
  ours <- if (start <= length(held)) Filter(function(r) r$start <= rel && mine(r), held[start:length(held)]) else list()
  passes <- 0
  if (length(ours) > 1) for (i in 2:length(ours)) if (ours[[i]]$id != ours[[i - 1]]$id) passes <- passes + 1

  kinds <- c(rush = rush, breakaway = breakaway, oddman = oddman, onetimer = onetimer, cross = cross,
             traffic = traffic > 0, behind = behind, forecheck = forecheck)
  tibble::tibble(
    game_id = attr(frames, "game_id") %||% NA, event_id = attr(frames, "event_id") %||% NA,
    team = team, goal_frame = ids[[gi]], release_frame = ids[[rel]],
    shooter = pid(shooter), distance = round(dist, 1), shot_speed = if (speed) round(speed, 1) else NA_real_,
    since_neutral = since, passes = passes,
    rush = rush, breakaway = breakaway, oddman = oddman, onetimer = onetimer, cross = cross,
    traffic = traffic > 0, behind = behind, forecheck = forecheck,
    kinds = paste(names(kinds)[kinds], collapse = ", "),
    carrier = carrier, xpass = xpass, otpass = if (onetimer) pid(passer$id) else NA_real_,
    bnpass = if (behind) pid(passer$id) else NA_real_, fcwin = fcwin, screens = list(screens)
  )
}

#' A goal's context from the play-by-play
#'
#' Looks back from a goal to the last stoppage: a rebound (the same club had
#' a shot on goal in the 3 seconds before) and a goal off a faceoff the club
#' won in the offensive zone, or lost in its own (within 10 seconds).
#'
#' @param pbp Play-by-play from [nhl_pbp()].
#' @param event_id The goal's event id.
#' @return A one-row tibble: `event_id`, `rebound`, `faceoff`.
#' @export
#' @examplesIf interactive()
#' pbp <- nhl_pbp(2025020534)
#' goal_context(pbp, 777)
goal_context <- function(pbp, event_id) {
  pbp <- pbp[order(pbp$sort_order), ]
  i <- which(pbp$event_id == event_id & pbp$type == "goal")
  if (!length(i)) cli::cli_abort("No goal with event id {event_id} in this play-by-play.")
  g <- pbp[i[[1]], ]
  rebound <- FALSE; faceoff <- FALSE
  if (i > 1) for (j in (i - 1):1) {
    q <- pbp[j, ]
    if (!identical(q$period, g$period) || g$period_seconds - q$period_seconds > 10) break
    if (q$type == "shot-on-goal" && identical(q$event_team, g$event_team) && g$period_seconds - q$period_seconds <= 3) rebound <- TRUE
    if (q$type == "faceoff") {
      won <- identical(q$event_team, g$event_team)
      faceoff <- (won && identical(q$zone_code, "O")) || (!won && identical(q$zone_code, "D"))
      break
    }
    if (q$type %in% c("stoppage", "period-start", "goal", "penalty")) break
  }
  tibble::tibble(event_id = event_id, rebound = rebound, faceoff = faceoff)
}
