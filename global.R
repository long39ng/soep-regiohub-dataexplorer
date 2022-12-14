library(shiny)
library(gridlayout)
library(bslib)
library(prompter)
library(shinyjs)
library(leaflet)
library(echarts4r)
library(dplyr)

var_names <- c(
  "pop_density",
  "hospital_beds",
  "bmi",
  "satisfaction_health",
  "worries_finances",
  "satisfaction_life",
  "turnout",
  "trust",
  "soziologie"
) |>
  setNames(nm = _)

data_long_nuts1 <- lapply(
  var_names,
  \(x) readRDS(paste0("data/", x, "_long_nuts1.RDS"))
)

data_long_nuts3 <- lapply(
  var_names,
  \(x) readRDS(paste0("data/", x, "_long_nuts3.RDS"))
)

data_wide_nuts1 <- lapply(
  var_names,
  \(x) readRDS(paste0("data/", x, "_wide_nuts1.RDS"))
)

data_wide_nuts3 <- lapply(
  var_names,
  \(x) readRDS(paste0("data/", x, "_wide_nuts3.RDS"))
)

de_maps <- readRDS("data/de_maps.RDS")

# sf::st_bbox(de_nuts1)
de_bbox <- c(xmin = 5.87709, ymin = 47.27011, xmax = 15.03355, ymax = 55.05428)

hospitals <- readRDS("data/hospitals.RDS")

metadata <- readRDS("data/metadata.RDS")[var_names, ]
