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

cli::cli_h1("Packages")

# parameters -------------------------------------------------------------
cli::cli_h1("Parameters")

chrome_path  <- "C:/Program Files/Google/Chrome/Application/chrome.exe"
preview_port <- 8000
# server_base_url <- "https://jbkunst.shinyapps.io"

# helpers ----------------------------------------------------------------
cli::cli_h1("Helpers")

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

quarto_render_catch <- function() {
  tryCatch(
    {
      quarto::quarto_render(".", quarto_args = "--no-clean")
      list(ok = TRUE, status = 0, output = "Quarto render completed.")
    },
    error = function(e) {
      list(ok = FALSE, status = "failed", output = conditionMessage(e))
    }
  )
}

screenshot_generate_and_copy <- function(app, slug) {
  screenshot <- path(app, "screenshot.png")

  if (!file_exists(screenshot)) {
    tryCatch(
      webshot2::appshot(app, file = screenshot, delay = 10, vwidth = 1440, vheight = 900),
      error = function(e) cli::cli_alert_warning("{app}: screenshot failed: {conditionMessage(e)}")
    )
  }

  image <- "site-assets/placeholder.svg"

  if (file_exists(screenshot)) {
    image <- path("site-assets", "screenshots", paste0(slug, ".png"))
    file_copy(screenshot, image, overwrite = TRUE)
  }

  chartr("\\", "/", image)
}

shinylive_export_catch <- function(meta) {
  cli::cli_h2(glue("Exporting Shinylive app: {meta$app}"))

  tryCatch(
    {
      shinylive::export(
        meta$app,
        "docs/live",
        subdir = meta$slug,
        template_params = list(title = meta$title)
      )

      index_file <- path("docs/live", meta$slug, "index.html")

      if (file_exists(index_file)) {
        list(status = "exported", message = "Shinylive export completed.")
      } else {
        list(status = "missing_index", message = "Shinylive export completed, but index.html is missing.")
      }
    },
    error = function(e) {
      list(status = "failed", message = conditionMessage(e))
    }
  )
}

# setup ------------------------------------------------------------------
cli::cli_h1("Setup")

if (file_exists("apps.yml")) file_delete("apps.yml")
if (dir_exists("docs"))      dir_delete("docs")

dir_create(c("site-assets/screenshots", "docs", "docs/live"))
writeLines("", "docs/.nojekyll", useBytes = TRUE)

if (interactive()) {
  httpuv::runStaticServer("docs", port = preview_port, browse = FALSE, background = TRUE)
}

if (!file_exists("site-assets/placeholder.svg")) {
  writeLines(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900"><rect width="1600" height="900" fill="#f5f7f8"/><text x="80" y="820" font-family="Arial" font-size="72" fill="#111315">Preview coming soon</text></svg>',
    "site-assets/placeholder.svg"
  )
}

# find apps ---------------------------------------------------------------
cli::cli_h1("Find apps")

app_dirs <- dir() |>
  keep(~ file_exists(path(.x, "DESCRIPTION"))) |>
  discard(~ .x %in% c("app-template", "docs")) |>
  discard(~ startsWith(.x, "."))

app_dirs

apps <- map_dfr(app_dirs, function(app = "arma-process") {
  desc <- read.dcf(path(app, "DESCRIPTION"))
  desc <- as.list(desc[1, , drop = TRUE])

  tibble(
    app = app,
    title = value(desc, "Title"),
    description = value(desc, "Description"),
    slug = app,
    categories = list(as_csv(value(desc, "Categories"))),
    # Si no tiene `Runtime` default is shinylive
    runtime = str_to_lower(value(desc, "Runtime", "shinylive")),
    status = str_to_lower(value(desc, "Status"))
  )
})

apps

draft_apps <- apps |>
  filter(.data$status == "draft")

if (nrow(draft_apps) > 0) {
  cli::cli_alert_info("Draft apps skipped: {paste(draft_apps$app, collapse = ', ')}")
  apps <- apps |>
  filter(.data$status != "draft")
}

if (nrow(apps) == 0) {
  stop("No app DESCRIPTION files found.", call. = FALSE)
}

metadata_errors <- apps |>
  mutate(
    missing = pmap_chr(
      list(.data$title, .data$description, .data$categories, .data$runtime),
      function(title, description, categories, runtime) {
        missing <- c(
          if (!nzchar(title)) "Title",
          if (!nzchar(description)) "Description",
          if (length(categories) == 0) "Categories",
          if (!runtime %in% c("shinylive", "publisher", "server")) "Runtime"
        )

        paste(missing, collapse = ", ")
      }
    )
  ) |>
  filter(nzchar(.data$missing))

if (nrow(metadata_errors) > 0) {
  stop(
    paste(glue("{metadata_errors$app}: missing {metadata_errors$missing}"), collapse = "\n"),
    call. = FALSE
  )
}

# shinylive ---------------------------------------------------------------
cli::cli_h1("Shinylive")

shinylive_apps <- apps |>
  filter(.data$runtime == "shinylive")

server_apps <- apps |>
  filter(.data$runtime %in% c("publisher", "server"))

if (nrow(server_apps) > 0) {
  cli::cli_alert_info("Server apps skipped by Shinylive: {paste(server_apps$app, collapse = ', ')}")
}

shinylive_results <- shinylive_apps$app |>
  set_names() |>
  map(function(app = "matrix-decompositions") {
    meta <- shinylive_apps |> filter(.data$app == .env$app) |> slice(1)
    result <- shinylive_export_catch(meta)

    if (interactive() && result$status == "exported") {
      browseURL(glue("http://127.0.0.1:{preview_port}/live/{meta$slug}/index.html"), browser = chrome_path)
    }

    result
  })

# Useful while developing one app locally.
# app <- "matrix-decompositions"
# shinylive::export(app, "docs/live", subdir = app)
# browseURL(glue("http://127.0.0.1:{preview_port}/live/{app}/index.html"), browser = chrome_path)

shinylive_ok     <- names(keep(shinylive_results,    ~ .x$status == "exported"))
shinylive_failed <- names(discard(shinylive_results, ~ .x$status == "exported"))

if (length(shinylive_failed) > 0) {
  shinylive_failed |>
    walk(function(app) {
      msg <- shinylive_results[[app]]$message |>
        cli::ansi_strip() |>
        str_extract("Can't find GitHub release for [^\\n]+")

      cli::cli_alert_info('App "{app}": {msg}')
    })
}

cards_shinylive <- shinylive_ok |>
  map(function(app = "matrix-decompositions") {
    meta <- shinylive_apps |> filter(.data$app == .env$app) |> slice(1)
    image <- screenshot_generate_and_copy(meta$app, meta$slug)

    list(
      title = meta$title,
      description = meta$description,
      image = image,
      categories = meta$categories[[1]],
      path = as.character(glue("live/{meta$slug}/index.html"))
    )
  }) |>
  set_names(shinylive_ok)

render_shinylive <- list(ok = NA, status = "skipped", output = "No Shinylive catalog rendered.")

if (length(cards_shinylive) > 0) {
  
  write_yaml(unname(cards_shinylive), "apps.yml")

  render_shinylive <- quarto_render_catch()

  if (!render_shinylive$ok) stop(glue("Quarto render failed: {render_shinylive$output}"), call. = FALSE)

  if (interactive()) browseURL(glue("http://127.0.0.1:{preview_port}/index.html"), browser = chrome_path)
}

# server -----------------------------------------------------------------
cli::cli_h1("Server")

server_candidates <- bind_rows(
  server_apps,
  shinylive_apps |> filter(.data$app %in% shinylive_failed)
) |>
  distinct(.data$app, .keep_all = TRUE)

if (nrow(server_candidates) > 0) {
  cli::cli_alert_info("Server candidates: {paste(server_candidates$app, collapse = ', ')}")
}

server_ready <- server_candidates |>
  filter(nzchar(.data$url))

server_pending <- server_candidates |>
  filter(!nzchar(.data$url))

if (nrow(server_pending) > 0) {
  cli::cli_alert_warning("Needs server deploy URL: {paste(server_pending$app, collapse = ', ')}")

  walk(server_pending$app, function(app = "kmeans-images") {
    meta <- server_pending |> filter(.data$app == .env$app) |> slice(1)
    cli::cli_alert_info('Deploy manually: rsconnect::deployApp("{meta$app}", appName = "{meta$slug}", appTitle = "{meta$title}")')
  })
}

cards_server <- server_ready$app |>
  map(function(app = "kmeans-images") {
    meta <- server_ready |> filter(.data$app == .env$app) |> slice(1)
    image <- screenshot_generate_and_copy(meta$app, meta$slug)

    list(
      title = meta$title,
      description = meta$description,
      image = image,
      categories = meta$categories[[1]],
      path = meta$url
    )
  }) |>
  set_names(server_ready$app)

cards_server <- compact(cards_server)

if (length(cards_server) > 0) {
  if (file_exists("apps.yml")) {
    cat("\n", file = "apps.yml", append = TRUE)
    cat(as.yaml(unname(cards_server)), file = "apps.yml", append = TRUE)
  } else {
    write_yaml(unname(cards_server), "apps.yml")
  }
} else {
  cli::cli_alert_info("No server cards to write.")
}

render_server <- NULL

if (length(cards_server) > 0) {
  cli::cli_h2("Rendering final catalog")
  render_server <- quarto_render_catch()

  if (!render_server$ok) {
    stop(glue("Quarto render failed: {render_server$output}"), call. = FALSE)
  }

  if (interactive()) {
    browseURL(glue("http://127.0.0.1:{preview_port}/index.html"), browser = chrome_path)
  }
}

# report -----------------------------------------------------------------
cli::cli_h1("Report")

shinylive_status <- map_chr(apps$app, function(app = "matrix-decompositions") {
  if (!app %in% names(shinylive_results)) return("not_requested")
  shinylive_results[[app]]$status
})

shinylive_message <- map_chr(apps$app, function(app = "matrix-decompositions") {
  if (!app %in% names(shinylive_results)) return("Runtime is not shinylive.")
  shinylive_results[[app]]$message
})

report_apps <- apps |>
  mutate(
    shinylive = shinylive_status,
    shinylive_message = shinylive_message,
    final_target = case_when(
      .data$app %in% shinylive_ok ~ "shinylive",
      .data$app %in% server_ready$app ~ "server",
      .data$app %in% server_pending$app ~ "server_pending",
      TRUE ~ "none"
    ),
    launch_url = case_when(
      .data$app %in% shinylive_ok ~ paste0("live/", .data$slug, "/index.html"),
      nzchar(.data$url) ~ .data$url,
      TRUE ~ ""
    )
  ) |>
  select(
    .data$slug,
    .data$runtime,
    .data$final_target,
    .data$launch_url,
    .data$shinylive,
    .data$shinylive_message
  )

build_report <- list(
  generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  app_count = nrow(apps),
  draft_apps = draft_apps$app,
  shinylive_ok = shinylive_ok,
  shinylive_failed = shinylive_failed,
  server_ready = server_ready$app,
  server_pending = server_pending$app,
  apps = report_apps,
  render_shinylive = render_shinylive,
  render_server = render_server
)

write_json(build_report, "site-build-report.json", pretty = TRUE, auto_unbox = TRUE)
write_json(build_report, "docs/build-report.json", pretty = TRUE, auto_unbox = TRUE)

# done -------------------------------------------------------------------
cli::cli_h1("Done")

message("Wrote apps.yml")
message("Wrote site-build-report.json")
message("Rendered Quarto site to docs/")
