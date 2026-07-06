**K-means clustering, step by step**

This app shows how the K-means algorithm updates cluster assignments through its internal iterations.

The main chart shows:

* simulated groups by shape,
* assigned clusters by color,
* cluster centers as large points,
* Voronoi boundaries around the current centers.

The generated-vs-assigned heatmap compares the original simulated groups with the clusters found by K-means. It is not a confusion matrix, because K-means cluster labels are arbitrary. The colors are only a visual guide to follow each assigned cluster across the app.

The charts below summarize within-cluster variation, convergence over iterations, and the final elbow curve for different values of (k).

**Resources and inspiration**

* [K-means Cluster Analysis](https://uc-r.github.io/kmeans_clustering) by UC Business Analytics R Programming Guide.
* [K-means shiny example](https://shiny.rstudio.com/gallery/kmeans-example.html).
* [Clustering algorithms](https://nms.kcl.ac.uk/colin.cooper/teachingmaterial/CSMWAL/CSMWAL/Lectures/ClusterSlides.pdf).

App made by [Joshua Kunst](https://jkunst.com) with ❤️, ☕, and ✨ (Shiny for R). Code [here](https://github.com/jbkunst/shiny-apps-educational).