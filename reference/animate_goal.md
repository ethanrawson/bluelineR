# Animate a goal as an MP4

Writes a goal's tracking replay as a video: every skater, both goalies
and the puck on the rink, positions eased between the ten-a-second
tracking frames, each player's sweater number in his club's colors, the
puck's trail, the scorer ringed with his skating speed above him, the
moment it went in, and then the last three seconds again at half speed.
The rink is in feet from centre ice, as everywhere in bluelineR.

## Usage

``` r
animate_goal(
  frames,
  file = "goal.mp4",
  goal = NULL,
  team = NULL,
  fps = 30,
  slow_motion = TRUE,
  width = 1280,
  height = 720,
  title = NULL,
  logos = FALSE,
  centre_logo = NULL
)
```

## Arguments

- frames:

  Tracking frames from
  [`nhl_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md)
  or
  [`read_goal_tracking()`](https://ethanrawson.github.io/bluelineR/reference/read_goal_tracking.md).

- file:

  Where to write the video (`.mp4`; `.gif` and `.webm` work too).

- goal:

  Optional: the goal from
  [`nhl_goal_replay()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md).

- team:

  The scoring club, when `goal` is not given and it cannot be worked out
  from the frames (empty-net goals).

- fps:

  Frames per second.

- slow_motion:

  Replay the three seconds before the goal at half speed.

- width, height:

  Size in pixels.

- title:

  Title; `NULL` for the scorer, period and clock when `goal` is given.

- logos:

  Draw the clubs' logos (from `goal`, which has their addresses). Needs
  the rsvg package.

- centre_logo:

  The URL or path of a logo for centre ice, in place of the home club's:
  an SVG (needs rsvg) or a PNG (needs png).

## Value

`file`, invisibly.

## Details

Pass the goal from
[`nhl_goal_replay()`](https://ethanrawson.github.io/bluelineR/reference/nhl_goal_tracking.md)
as `goal` to name the scorer and his assists on the ice and title the
video; without it the scorer is the shooter
[`classify_goal()`](https://ethanrawson.github.io/bluelineR/reference/classify_goal.md)
finds and nobody is named.

With `logos = TRUE` the clubs' logos stand in for their abbreviations in
the title and the home club's logo goes on centre ice; `centre_logo`
puts another there, like a special event's.

Frames are drawn with base graphics and encoded by the av package (H.264
where FFmpeg has it); a full-size clip takes under a minute.

## Examples

``` r
if (FALSE) { # interactive() && requireNamespace("av", quietly = TRUE)
frames <- nhl_goal_tracking(2025020534, 777)
animate_goal(frames, "mcdavid.mp4", goal = nhl_goal_replay(2025020534, 777))

# McDavid's overtime winner in the 4 Nations final, with the logos:
four_nations <- paste0("https://raw.githubusercontent.com/ethanrawson/bluelineR/Model/",
                       "man/figures/4-nations-logo.png")
animate_goal(nhl_goal_tracking(2024200007, 1443), "4-nations.mp4",
             goal = nhl_goal_replay(2024200007, 1443), logos = TRUE, centre_logo = four_nations)

# Offline, from the copy that ships with the package:
path <- system.file("extdata", "goal-2025020534-777.json.gz", package = "bluelineR")
animate_goal(read_goal_tracking(path, 2025020534, 777), tempfile(fileext = ".mp4"), team = "EDM")
}
```
