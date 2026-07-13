# packages ---------------------------------------------------------------
library(dplyr)
library(purrr)
library(stringr)
library(tibble)
library(fs)
library(glue)
library(yaml)
library(jsonlite)
library(cli)

# parameters -------------------------------------------------------------
chrome_path <- "C:/Program Files/Google/Chrome/Application/chrome.exe"

# helpers ----------------------------------------------------------------
value <- function(desc, name, default = "") {
  x <- desc[[name]]
  if (is.null(x) || is.na(x) || !nzchar(x)) x <- default

  x |>
    str_replace_all("[\r\n\t]+", " ") |>
    str_squish()
}

as_csv <- function(x) {
  x <- str_squish(x)
  if (!nzchar(x)) return(character())

  x |>
    str_split(",") |>
    pluck(1) |>
    str_squish() |>
    discard(~ !nzchar(.x))
}

set_html_title <- function(file, title) {
  html <- readLines(file, encoding = "UTF-8", warn = FALSE)
  html <- str_replace(
    html,
    "<title>.*</title>",
    glue("<title>{htmltools::htmlEscape(title)}</title>")
  )
  writeLines(html, file, useBytes = TRUE)
}

# site files --------------------------------------------------------------
dir_create(c("site-assets/screenshots", "docs"))

if (!file_exists("site-assets/placeholder.svg")) {
  writeLines(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900"><rect width="1600" height="900" fill="#f5f7f8"/><text x="80" y="820" font-family="Arial" font-size="72" fill="#111315">Preview coming soon</text></svg>',
    "site-assets/placeholder.svg"
  )
}

# find apps ---------------------------------------------------------------
apps <- dir() |>
  keep(~ file_exists(path(.x, "DESCRIPTION"))) |>
  discard(~ .x %in% c("app-template", "docs")) |>
  discard(~ startsWith(.x, "."))

apps

apps <- map_dfr(apps, function(app = "arma-process") {
  
  desc <- read.dcf(path(app, "DESCRIPTION"))
  desc <- as.list(desc[1, , drop = TRUE])

  tibble(
    app = app,
    title = value(desc, "Title"),
    description = value(desc, "Description"),
    slug = app,
    categories = list(as_csv(value(desc, "Categories"))),
    runtime = str_to_lower(value(desc, "Runtime", "shinylive")),
    url = value(desc, "URL")
  )
})

apps

if (nrow(apps) == 0) {
  stop("No app DESCRIPTION files found.", call. = FALSE)
}

# cards ------------------------------------------------------------------
app_results <- purrr::map(apps$app, function(app = "matrix-decompositions") {
  meta <- apps |> filter(.data$app == .env$app) |> slice(1)
  slug <- meta$slug

  cli::cli_progress_step(app)

  missing <- c(
    if (!nzchar(meta$title)) "Title",
    if (!nzchar(meta$description)) "Description",
    if (length(meta$categories[[1]]) == 0) "Categories",
    if (!meta$runtime %in% c("shinylive", "publisher", "server")) "Runtime"
  )

  if (length(missing) > 0) {
    return(list(
      card = NULL,
      report = NULL,
      errors = glue("{app}: missing {paste(missing, collapse = ', ')}")
    ))
  }

  screenshot         <- path(app, "screenshot.png")
  screenshot_status  <- if (file_exists(screenshot)) "existing" else "missing"
  screenshot_message <- if (file_exists(screenshot)) "Existing screenshot found." else "No screenshot found."

  if (!file_exists(screenshot)) {
    screenshot_result <- tryCatch(
      {
        webshot2::appshot(app, file = screenshot, delay = 10, vwidth = 1440, vheight = 900)

        if (file_exists(screenshot)) {
          list(status = "created", message = "Screenshot created.")
        } else {
          list(status = "failed", message = "Screenshot file was not created.")
        }
      },
      error = function(e) list(status = "failed", message = conditionMessage(e))
    )

    screenshot_status <- screenshot_result$status
    screenshot_message <- screenshot_result$message
  }

  image <- "site-assets/placeholder.svg"

  if (file_exists(screenshot)) {
    image <- path("site-assets", "screenshots", paste0(slug, ".png"))
    file_copy(screenshot, image, overwrite = TRUE)
  }

  launch_url <- case_when(
    meta$runtime == "shinylive" ~ glue("live/{slug}/index.html"),
    meta$runtime %in% c("publisher", "server") && nzchar(meta$url) ~ meta$url,
    TRUE ~ ""
  )

  app_errors <- character()

  if (!nzchar(launch_url)) {
    app_errors <- c(app_errors, glue("{app}: no launch URL available"))
  }

  list(
    card = list(
      title = meta$title,
      description = meta$description,
      image = chartr("\\", "/", image),
      categories = meta$categories[[1]],
      path = as.character(launch_url)
    ),
    report = list(
      slug = slug,
      runtime = meta$runtime,
      launch_url = as.character(launch_url),
      screenshot = screenshot_status,
      screenshot_message = screenshot_message,
      shinylive = "not_requested",
      shinylive_message = "Runtime is not shinylive."
    ),
    errors = app_errors
  )
})

# Split the per-app results into the two outputs used later.
app_results <- set_names(app_results, apps$slug)
cards       <- app_results |> map("card") |> compact()
report_apps <- app_results |> map("report") |> compact()
errors      <- unlist(map(app_results, "errors"), use.names = FALSE)

write_yaml(unname(cards), "apps.yml")

# render -----------------------------------------------------------------
render_result <- tryCatch(
  {
    quarto::quarto_render(".")
    list(ok = TRUE, status = 0, output = "Quarto render completed.")
  },
  error = function(e) {
    list(ok = FALSE, status = "failed", output = conditionMessage(e))
  }
)

if (!render_result$ok) {
  stop(glue("Quarto render failed: {render_result$output}"), call. = FALSE)
}

writeLines("", "docs/.nojekyll", useBytes = TRUE)

local_url <- NULL

if (interactive()) {
  local_server <- httpuv::runStaticServer("docs", host = "127.0.0.1", background = TRUE, browse = FALSE)
  local_url <- glue("http://{local_server$getHost()}:{local_server$getPort()}")
  browseURL(glue("{local_url}/index.html"), browser = chrome_path)
}

# shinylive ---------------------------------------------------------------
shinylive_exported <- FALSE

if (dir_exists("docs/live")) dir_delete("docs/live")
dir_create("docs/live")

# Export Shinylive apps after Quarto renders, because docs/ is the output dir.
shinylive_results <- apps |>
  filter(.data$runtime == "shinylive") |>
  pull(.data$app) |>
  set_names() |>
  purrr::map(function(app = "matrix-decompositions") {

    cli::cli_h2(glue("Exporting Shinylive app: {app}"))

    meta <- apps |> filter(.data$app == .env$app) |> slice(1)
    slug <- meta$slug

    export_result <- tryCatch(
      {
        shinylive::export(app, "docs/live", subdir = slug)
        index_file <- path("docs/live", slug, "index.html")
        ok <- file_exists(index_file)

        if (ok) {
          set_html_title(index_file, meta$title)
          list(status = "exported", message = "Shinylive export completed.")
        } else {
          list(status = "missing_index", message = "Shinylive export completed, but index.html is missing.")
        }
      },
      error = function(e) {
        list(status = "failed", message = conditionMessage(e))
      }
    )

    if (interactive() && export_result$status == "exported") {
      browseURL(glue("{local_url}/live/{slug}/index.html"), browser = chrome_path)
    }

    export_result

  })

# Merge Shinylive export results back into the build report entries.
for (slug in names(shinylive_results)) {
  if (!is.null(report_apps[[slug]])) {
    report_apps[[slug]]$shinylive <- shinylive_results[[slug]]$status
    report_apps[[slug]]$shinylive_message <- shinylive_results[[slug]]$message
  }
}

shinylive_exported <- length(shinylive_results) > 0

# report -----------------------------------------------------------------
build_report <- list(
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  app_count = nrow(apps),
  apps = unname(report_apps),
  render = render_result,
  shinylive_exported = shinylive_exported,
  fatal_errors = errors
)

write_json(build_report, "site-build-report.json", pretty = TRUE, auto_unbox = TRUE)
write_json(build_report, "docs/build-report.json", pretty = TRUE, auto_unbox = TRUE)

if (length(errors) > 0) {
  stop(paste(errors, collapse = "\n"), call. = FALSE)
}

# done -------------------------------------------------------------------
message("Wrote apps.yml")
message("Wrote site-build-report.json")
message("Rendered Quarto site to docs/")
