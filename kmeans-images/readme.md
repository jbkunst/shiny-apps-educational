Every image is a grid of pixels. Each pixel has an RGB color, so it can be represented as a point in color space.

This app applies K-means to the pixels and rebuilds the image from the cluster centers. A small value of \\(k\\) creates a stronger compression effect; a larger value keeps more color detail.

When pixel position is enabled, each pixel is clustered with both color and location: \\((r_i, g_i, b_i, x_i, y_i)\\). This makes nearby pixels more likely to share the same cluster.

The idea is inspired by [dsparks' kmeans palette](https://gist.github.com/dsparks/3980277). This version adds 3D scatterplots and an interactive Shiny workflow.
