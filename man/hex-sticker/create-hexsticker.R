# Load packages -----
library(tidyverse)
library(hexSticker)
library(sysfonts)
library(magick)


# View and select font -----
fonts_dataset <- font_files()

font_add("Calibri italic", "calibrii.ttf")
font_add("Calibri", "calibri.ttf")
font_add("Arial", "arial.ttf")

# Create the sticker -----
on_screenshot <- image_read('man/hex-sticker/opennem_screenshot.png')

sticker(
  subplot = on_screenshot,
  package = "opennemr",
  s_width = 1.72,
  s_height = 4,
  s_x = 1,
  s_y = 1,
  h_fill = "white",
  h_color = "#c6c1be",
  h_size = 2.5,
  # # url = "https://github.com/RPBatchelor/opennemr",
  # # u_size = 2,
  # # u_color = "white",
  # spotlight = TRUE,
  p_size = 20,
  p_color = "#797674",
  p_family = "Arial",
  p_x = 0.98,
  p_y = 1.53,
  # dpi = 300,
  # asp = 1,
  white_around_sticker = TRUE,
  filename = "man/hex-sticker/opennem-logo.png"
) |>
  print()
