# The hex logo: a puck crossing the blue line, in the BluelineMetrics blue.
library(ggplot2)
hex <- data.frame(x = cos(seq(pi / 6, 2 * pi + pi / 6, length.out = 7)), y = sin(seq(pi / 6, 2 * pi + pi / 6, length.out = 7)))
trail <- data.frame(x = seq(-0.62, 0.2, length.out = 40), y = -0.14 + 0.06 * sin(seq(0, pi, length.out = 40)))
p <- ggplot() +
  geom_polygon(data = hex, aes(x, y), fill = "#0b1220", colour = "#1565FF", linewidth = 3.2) +
  geom_segment(aes(x = -0.08, xend = -0.08, y = -0.5, yend = 0.22), colour = "#1565FF", linewidth = 5.5) +
  geom_path(data = trail, aes(x, y), colour = "#93c5fd", linewidth = 1.6, alpha = 0.7, lineend = "round") +
  geom_point(aes(x = 0.3, y = -0.14), size = 16, colour = "#f7f9fc") +
  geom_point(aes(x = 0.3, y = -0.14), size = 11, colour = "#1f2937") +
  annotate("text", x = 0, y = 0.48, label = "bluelineR", colour = "#f7f9fc", size = 10.5, fontface = "bold") +
  annotate("text", x = 0, y = -0.66, label = "NHL data, tracked", colour = "#93c5fd", size = 4.4, fontface = "bold") +
  coord_fixed(xlim = c(-1.02, 1.02), ylim = c(-1.02, 1.02), expand = FALSE) +
  theme_void() + theme(plot.background = element_rect(fill = "transparent", colour = NA))
ggsave("man/figures/logo.png", p, width = 3.6, height = 4, dpi = 160, bg = "transparent")
