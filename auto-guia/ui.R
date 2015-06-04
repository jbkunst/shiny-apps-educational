dashboardPage(
  dashboardHeader(title = "Basic dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Crear guía", tabName = "guia_crear", icon = icon("file-pdf-o")),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
      )
    ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "guia_crear",
              fluidRow(
                box(
                  sliderInput("integer", "Integer:", min=1, max=10, value=5),
                    downloadLink('pdflink')
                    
                  ),
                box(
                  )
                )
              )
      )
    )
  )
    
