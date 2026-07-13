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
```

The app slug is the folder name. Do not duplicate it in metadata.

`Runtime` is optional. If it is missing, the build assumes:

```text
Runtime: shinylive
```

Use `Runtime` only when the default is not correct:

- `shinylive`: exported to `docs/live/<app-folder>/`.
- `server`: linked to `https://jbkunst.shinyapps.io/<app-folder>`.
- `publisher`: reserved for external hosting if needed later.

If an app does not work in Shinylive, keep it in the gallery and change its
runtime to `server` once it is deployed to shinyapps.io.

Draft apps can stay in the repository without being published:

```text
Status: draft
```

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

The script is intentionally organized as a two-phase publishing flow.

### Setup

At the start of a full build, the script deletes generated site state:

```text
apps.yml
docs/
```

Then it scans top-level app folders with `DESCRIPTION`, skips `Status: draft`,
and prepares screenshots and site assets.

### Phase 1: Shinylive

The first publishing pass tries Shinylive for every app whose `Runtime` is
missing or set to `shinylive`.

Successful Shinylive apps are written to `apps.yml` with links like:

```text
live/<app-folder>/index.html
```

Then Quarto renders an intermediate gallery into `docs/`. This gives a useful
site even before every app has a server deployment.

Apps with `Runtime: server` or `Runtime: publisher` are skipped in this phase.
Apps that fail Shinylive are carried forward to the server phase.

### Phase 2: Server Apps

The second pass collects:

- apps explicitly marked `Runtime: server` or `Runtime: publisher`;
- apps that failed the Shinylive export.

For server apps, the build derives the public URL from the folder name:

```text
https://jbkunst.shinyapps.io/<app-folder>
```

Those cards are appended to `apps.yml` and Quarto renders the final gallery
again.

If an app needs server hosting, deploy it manually with a command like:

```r
rsconnect::deployApp(
  "kmeans-images",
  appName = "kmeans-images",
  appTitle = "K-means on Images"
)
```

After the deployment succeeds, rerun the server phase or the full script and
render the final gallery.

The server phase appends to `apps.yml` instead of rewriting it. This makes it
possible to run the Shinylive phase first, publish that intermediate site, and
later continue from the server section in the same R session after server apps
are deployed. Do not rerun the setup section when continuing from the server
section, because setup intentionally deletes `apps.yml` and `docs/`.

When run interactively, the script opens the generated site in Chrome if
`chrome_path` is valid in `R/build_site.R`.

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
