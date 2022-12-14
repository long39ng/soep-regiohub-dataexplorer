grid_page(
  theme = bs_add_rules(
    bs_theme(version = 5),
    readLines("www/misc.css")
  ),
  layout = c(
    "header          header header                  header_right           ",
    "controller_left map    charts_legend_container charts_toggle_container",
    "controller_left map    charts_area             charts_area            ",
    "controller_left map    charts_footer           charts_footer          ",
    "footer          footer footer                  footer                 "
  ),
  row_sizes = c(
    "60px",
    "60px",
    "1fr",
    "60px",
    "30px"
  ),
  col_sizes = c(
    "0.25fr",
    "0.75fr",
    "0.8fr",
    "180px"
  ),
  gap_size = "15px",
  tags$head(
    tags$title("SOEP-RegioHub DataExplorer"),
    tags$base(target = "blank_")
  ),
  use_prompt(),
  useShinyjs(),
  tags$script(src = "misc.js"),
  grid_card_text(
    area = "header",
    content = span(
      class = "app-title",
      HTML("<a href='https://lsc-soep-regiohub.com/'><img alt='Leibniz ScienceCampus SOEP RegioHub logo' src='lwc-logo.svg' height=55px></a>"),
      "SOEP-RegioHub DataExplorer"
    ),
    h_align = "start",
    alignment = "start",
    wrapping_tag = "h3"
  ),
  grid_card_text(
    area = "header_right",
    content = HTML("<a href='https://kongress2022.soziologie.de/'><img alt='DGS Kongress 2022 logo' src='dgs-kongress-logo.svg' height=55px></a>"),
    alignment = "end"
  ),
  grid_card(
    area = "controller_left",
    item_gap = "12px",
    selectInput(
      inputId = "map_var",
      label = "Indikator",
      choices = setNames(var_names, metadata$title),
      selectize = FALSE
    ),
    checkboxInput(
      inputId = "map_log_scale",
      label = "Logarithmische Farbskala",
      value = FALSE,
      width = "100%"
    ),
    checkboxInput(
      inputId = "map_show_hospitals",
      label = "Krankenhäuser anzeigen",
      value = FALSE,
      width = "100%"
    ),
    hr(),
    actionButton(
      inputId = "drill_up",
      label = "Bundesländer",
      width = "100%"
    ),
    actionButton(
      inputId = "drill_down",
      label = "Kreise",
      width = "100%"
    ),
    hr(),
    actionButton(
      inputId = "unselect",
      label = "Auswahl aufheben",
      width = "100%"
    )
  ),
  grid_card(
    area = "map",
    item_gap = "12px",
    shinyWidgets::sliderTextInput(
      inputId = "year",
      label = "Jahr",
      choices = "",
      width = "60%"
    ),
    leaflet::leafletOutput("map_drill",
      height = "100%"
    ),
    textOutput("map_var_info")
  ),
  grid_card(
    area = "charts_legend_container",
    item_gap = "0",
    class = "echarts-legend-container",
    div(
      id = "echarts-legend",
      class = "echarts-common-legend"
    )
  ),
  grid_card(
    area = "charts_toggle_container",
    item_gap = "0",
    class = "echarts-toggle-container",
    checkboxInput(
      inputId = "chart_show_avg",
      label = "Bundesdurchschnitt",
      value = TRUE,
      width = "100%"
    )
  ),
  grid_card(
    area = "charts_area",
    item_gap = "0",
    class = "charts-panel",
    grid_container(
      flag_mismatches = FALSE,
      layout = c(
        "chart1 chart2",
        "chart3 chart4",
        "chart5 chart6",
        "chart7 chart8",
        "chart9 .     "
      ),
      row_sizes = c(
        "300px",
        "300px",
        "300px",
        "300px",
        "300px"
      ),
      col_sizes = c(
        "1fr",
        "1fr"
      ),
      gap_size = "0px",
      lapply(seq_along(var_names), \(x) {
        grid_card(
          area = paste0("chart", x),
          item_gap = "0",
          lineChartUI(var_names[[x]], metadata)
        )
      })
    )
  ),
  grid_card(
    area = "charts_footer",
    shinyWidgets::sliderTextInput(
      inputId = "charts_years",
      label = NULL,
      choices = as.character(1984:2021),
      selected = c("1984", "2021"),
      width = "50%"
    )
  ),
  grid_card_text(
    area = "footer",
    content = HTML(readLines("www/attribution.txt")[[1]]),
    wrapping_tag = "span"
  )
)
