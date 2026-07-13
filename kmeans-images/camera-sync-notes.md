# Camera Sync Note

An earlier version tried to synchronize the two 3D Plotly cameras with
`htmlwidgets::onRender()`, `plotlyProxy()`, and `www/camera-sync.js`.

It worked locally, but it was fragile in Shinylive. The first 3D plot could stay
empty because the data update depended on a browser-side ready event.

The current `app.R` renders both 3D plots directly. The old attempt is kept in
`app_w_sync.R` in case we want to revisit the idea later.
