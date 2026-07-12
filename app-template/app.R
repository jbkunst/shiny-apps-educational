# packages ----------------------------------------------------------------
library(shiny)
library(bslib)

# theme -------------------------------------------------------------------
apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)

card <- purrr::partial(bslib::card, full_screen = TRUE)

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    sidebar = sidebar(
      title = "App title"
    ),
    card(
      card_header("Main view"),
      card_body(
        p("Replace this content with the app UI.")
      )
    )
  )
)

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  # Add server logic here.
}

shinyApp(ui, server)
