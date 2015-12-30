dashboardPage(
  skin = "red",
  dashboardHeader(title = "ApplicationReport", disable = FALSE),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inventario", tabName = "inventario", icon = icon("list-ol")),
      menuItem("Solicitudes", tabName = "solicitudes", icon = icon("file-text-o")),
      menuItem("Performance", tabName = "performance", icon = icon("money")),
      menuItem("Uso Interno", tabName = "interno", icon = icon("pied-piper-alt"))
      ),
    hr(),
    selectInput("segmento", NULL, choices = segmento_choices),
    selectInput("path", NULL, choices = path_choices)
    ),
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/custom_fixs.css")),
    tabItems(
      tabItem(tabName = "inventario",
              h4("Inventario de Modelos")
      ),
      tabItem(tabName = "solicitudes",
              h4("Distribucion de Solicitudes por Periodo"),
              plotlyOutput("sols_per_plot", height = "300"),
              hr(), h4("Distribucion de Solicitudes por Periodo y RiskIndicator"),
              plotlyOutput("sols_per_ri_plot", height = "300"),
              hr(), h4("Distribucion de Solicitudes por Periodo y Resultado StrategyWare"),
              plotlyOutput("sols_per_swsol_plot", height = "300")
              ),
      tabItem(tabName = "performance",
              hr(), h4("Indicadores de Performance de Modelos por Periodo"),
              plotlyOutput("perd_per_sina", height = "600")
              )
      )
    )
  )
