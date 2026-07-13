# Camera Sync Note

An earlier version tried to synchronize the two 3D Plotly cameras with
`htmlwidgets::onRender()`, `plotlyProxy()`, and `www/camera-sync.js`.

It worked locally, but it was fragile in Shinylive. The first 3D plot could stay
empty because the data update depended on a browser-side ready event.

The current `app.R` keeps the camera sync version because this app is intended
to run on Posit Connect. The simpler no-sync version is kept in
`app_no_sync.R`.
