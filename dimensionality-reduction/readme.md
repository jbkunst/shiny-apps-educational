Compare four ways to represent high-dimensional data in two dimensions:

- **PCA** finds linear directions with maximum variance.
- **Isomap** replaces direct distances with shortest paths through a neighborhood graph.
- **t-SNE** focuses strongly on local neighborhoods.
- **UMAP** builds a low-dimensional map from a neighborhood graph.

Use **Type of data** to switch between real datasets and simulated shapes. Real datasets are sampled from prepared files; simulated datasets are generated on demand.

For real datasets, color shows the digit, clothing category, or mammoth region. For simulated datasets, color usually identifies the generated group. For **Swiss roll**, color follows position along the surface and should not be interpreted as a class.

Click a point in any map to highlight the same observation everywhere. The yellow points are its nearest neighbors in the observed high-dimensional data, so you can see which methods keep that local neighborhood together.

Use **Observed data** to inspect the data before projection. Two- and three-dimensional observed data are shown as plots; higher-dimensional data are shown as a small table focused on the selected point and its neighbors.

The axes from different methods are not directly comparable. A visually separated map can be useful, but it does not prove that real groups exist.
