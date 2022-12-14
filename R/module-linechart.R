lineChartUI <- function(id, metadata) {
  ns <- shiny::NS(id)

  metadata <- metadata[metadata$id == id, ]

  if (is.na(metadata$note)) {
    tooltip <- paste0(
      "Datenquelle:\n", metadata$source
    )
  } else {
    tooltip <- paste0(
      "Anmerkung:\n", metadata$note, "\n\n",
      "Datenquelle:\n", metadata$source
    )
  }

  shiny::tagList(
    shiny::div(
      class = "info-tooltip",
      metadata$title,
      shiny::icon("question", style = "font-size:60%;vertical-align:super;"),
      style = "margin-bottom: 12px; font-weight: 700;"
    ) |>
      prompter::add_prompt(
        message = tooltip,
        rounded = TRUE,
        size = "large"
      ),
    shiny::div(
      metadata$subtitle,
      style = "font-size:14px;line-height:1;color:#666;"
    ),
    echarts4r::echarts4rOutput(ns("chart"), height = "100%")
  )
}

lineChartServer <- function(id, data, leaflet_map) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      output$chart <- echarts4r::renderEcharts4r({
        data()[[id]] |>
          echarts4r::e_charts(year) |>
          echarts4r::e_line_("(Durchschnitt)") |>
          echarts4r::e_x_axis(
            axisLine = list(show = FALSE),
            axisTick = list(show = FALSE),
            data = as.character(1984:2021)
          ) |>
          echarts4r::e_y_axis(scale = TRUE) |>
          echarts4r::e_theme_custom(
            # Grey + Dynamic colour palette
            '{"color":["#DDDDDD","#DB9D85","#9DB469","#3DBEAB","#87AEDF","#DA95CC"]}'
          ) |>
          echarts4r::e_tooltip(
            order = "valueDesc",
            trigger = "axis",
            appendToBody = TRUE # Shown even when overflowing grid boundaries
          ) |>
          echarts4r::e_legend(FALSE) |>
          echarts4r::e_legend_select("(Durchschnitt)") |>
          echarts4r::e_datazoom(toolbox = FALSE, show = FALSE) |>
          echarts4r::e_text_style(
            fontFamily = "Roboto, sans-serif"
          )
      })

      # https://stackoverflow.com/a/41199134
      map_selected_regions <- shiny::reactiveValues(current = character(), last = character())

      shiny::observe({
        map_selected_regions$last <- map_selected_regions$current
        map_selected_regions$current <- leaflet_map$curr_sel_data()[["name"]]
      }) |>
        shiny::bindEvent(leaflet_map$curr_sel_data())

      current_regions <- shiny::reactive({
        intersect(map_selected_regions$current, names(data()[[id]]))
      })

      last_regions <- shiny::reactive(map_selected_regions$last)

      shiny::observe({
        added_regions <- setdiff(current_regions(), last_regions())

        removed_regions <- setdiff(last_regions(), current_regions())

        proxy <- echarts4r::echarts4rProxy(paste0(id, "-chart"), data()[[id]], year)

        if (length(added_regions)) {
          proxy |>
            Reduce(e_line_p_, added_regions, init = _) |>
            echarts4r::e_execute()
        }

        if (length(removed_regions)) {
          proxy |>
            Reduce(echarts4r::e_remove_serie_p, removed_regions, init = _)
        }
      })
    }
  )
}

e_line_p_ <- function(e, serie, bind, name = NULL, legend = TRUE,
                      y_index = 0, x_index = 0, coord_system = "cartesian2d", ...) {
  stopifnot(inherits(e, "echarts4rProxy"))
  stopifnot(is.character(serie) && length(serie) == 1L)
  if (missing(bind)) {
    bd <- NULL
  } else {
    bd <- deparse(substitute(bind))
  }
  e$chart <- echarts4r::e_line_(e$chart, serie, bd, name, legend, y_index, x_index, coord_system, ...)
  e
}

update_echarts_legend <- function(chart_id,
                                  session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage(type = "update-echarts-legend", message = chart_id)
}

highlight_selected_echart <- function(chart_id,
                                      session = shiny::getDefaultReactiveDomain()) {
  session$sendCustomMessage(type = "scrollto-and-highlight-echart", message = chart_id)
}
