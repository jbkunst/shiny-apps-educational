Compare four ways to represent high-dimensional data in two dimensions:

- **PCA** finds linear directions with maximum variance.
- **Isomap** replaces direct distances with shortest paths through a neighborhood graph.
- **t-SNE** focuses strongly on local neighborhoods.
- **UMAP** builds a low-dimensional map from a neighborhood graph.

For a visual explanation of UMAP, see [Understanding UMAP](https://pair-code.github.io/understanding-umap/).

Use **Type of data** to switch between real datasets and simulated shapes. Real datasets are sampled from prepared files; simulated datasets are generated on demand.

For real datasets, color shows the digit, clothing category, or mammoth region. For simulated datasets, color usually identifies the generated group. For **Swiss roll**, color follows position along the surface and should not be interpreted as a class.

Click a point in any map to highlight the same observation everywhere. The yellow points are its nearest neighbors in the observed high-dimensional data, so you can see which methods keep that local neighborhood together.

Use **Show data** to inspect three-dimensional observed data before projection.

The axes from different methods are not directly comparable. A visually separated map can be useful, but it does not prove that real groups exist.
