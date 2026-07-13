# Shiny Educational Apps

This repository contains small Shiny apps for teaching statistics, machine
learning, probability, and mathematical ideas.

The public entry point is the Quarto gallery generated into `docs/`. The README
is intentionally more internal: it documents how the gallery is built, how apps
are added, and how to decide whether an app should run with Shinylive or be
hosted elsewhere.

Public site:

<https://jbkunst.github.io/shiny-apps-educational/>

## Repository Structure

- `app-template/`: minimal app skeleton for new apps.
- `<app-folder>/`: one Shiny app per top-level folder.
- `<app-folder>/DESCRIPTION`: metadata used by the gallery builder.
- `<app-folder>/screenshot.png`: app preview used in the gallery.
- `R/build_site.R`: simple script that rebuilds the gallery.
- `R/run_app.R`: helper for running an app from a fresh copy of the repo.
- `index.qmd`: Quarto source for the gallery page.
- `apps.yml`: generated listing data consumed by Quarto.
- `site-assets/`: generated gallery assets before Quarto copies them to `docs/`.
- `docs/`: generated site published by GitHub Pages.

## App Metadata

Each app that should appear in the gallery needs a `DESCRIPTION` file.

Minimum fields:

```text
Title: App Title
Description: A short sentence that explains what learners can explore in the app.
Categories: statistics, simulation
Runtime: shinylive
URL:
```

The app slug is the folder name. Do not duplicate it in metadata.

`Runtime` can be:

- `shinylive`: exported to `docs/live/<app-folder>/`.
- `server`: linked to `URL`, usually shinyapps.io or another Shiny server.
- `publisher`: linked to `URL`, for Posit Publisher or similar hosting.

If an app does not work in Shinylive, keep it in the gallery and change its
runtime to `server` or `publisher` once a live URL exists.

## Adding A New App

1. Copy `app-template/` to a new top-level folder.
2. Use a short folder name; this becomes the app slug.
3. Build the app in `app.R`.
4. Fill in `DESCRIPTION`.
5. Add a short `readme.md` that explains how the app works.
6. Add or reuse a `credits.md` signature block.
7. Run the app locally and check the teaching flow.
8. Run `source("R/build_site.R")` from the repository root.
9. Check the generated gallery in `docs/index.html`.
10. If `Runtime: shinylive`, check `docs/live/<app-folder>/index.html`.
11. Commit the source changes separately from generated `docs/` changes when it
   helps review.

The build script creates `screenshot.png` only when it is missing. To regenerate
a screenshot, delete the old app screenshot and run the build again.

## Markdown Notes

Many apps include Markdown files inside the UI with
`htmltools::includeMarkdown()`. Keep reusable app text in `readme.md` and visible
signature text in `credits.md` when that makes the app easier to maintain.

Each app should have a `readme.md` focused on the app's "How it works" content.
This file should be useful on GitHub and also included inside the Shiny UI with
`htmltools::includeMarkdown("readme.md")`.

In the app UI, place the `readme.md` content inside a closed accordion before
the credits. If the app needs several explanatory blocks, create one accordion
section per block, but keep the credits visible and outside the accordion.

For MathJax inside included Markdown, write inline math with double backslashes:

```md
\\(k\\)
\\((r_i, g_i, b_i, x_i, y_i)\\)
```

The Markdown renderer consumes a single backslash, so writing `\(k\)` in the
source may produce plain `(k)` in the generated HTML instead of MathJax input.

## Rebuilding The Gallery

From an interactive R session at the repository root:

```r
source("R/build_site.R")
```

The script:

1. scans app folders with `DESCRIPTION`;
2. creates missing screenshots;
3. writes `apps.yml`;
4. renders the Quarto site to `docs/`;
5. exports Shinylive apps to `docs/live/`;
6. writes `site-build-report.json`.

When run interactively, it also opens the generated site and exported apps in
Chrome if `chrome_path` is valid in `R/build_site.R`.

## Publishing

GitHub Pages should be configured to serve:

```text
branch: master
folder: /docs
```

Manual publishing flow:

```powershell
git status
git add R/build_site.R index.qmd _quarto.yml apps.yml site-assets docs site-build-report.json
git commit -m "Update app gallery"
git push origin master
```

For app source changes, prefer more specific commits, for example:

```text
Add DESCRIPTION for new app
Update matrix decompositions for Shinylive
Publish rebuilt Quarto site
```

Later, this can move to GitHub Actions so `docs/` is rebuilt by CI instead of
being committed manually.

## Analyst And AI Workflow

The analyst should own the educational intent:

- what concept the app teaches;
- what interaction matters;
- what the learner should notice;
- whether the app is ready to publish.

An AI assistant can help with mechanical and review-heavy work:

- inspect all `DESCRIPTION` files for missing or noisy metadata;
- draft short English titles and descriptions;
- identify heavy dependencies or possible Shinylive blockers;
- simplify app code for browser execution;
- compare generated `apps.yml` against app folders;
- suggest commit boundaries;
- prepare a GitHub Actions workflow when manual publishing becomes annoying.

Keep changes small and reviewable. The gallery is only useful if adding a new app
stays simpler than maintaining a framework.

## Local App Helper

The helper can run an app from a fresh copy of the repository:

```r
source("https://raw.githubusercontent.com/jbkunst/shiny-apps-educational/master/R/run_app.R")
run_app("kmeans")
```
