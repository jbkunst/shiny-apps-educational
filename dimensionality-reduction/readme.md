Compare four ways to represent high-dimensional data in two dimensions:

- **PCA** finds linear directions with maximum variance.
- **Isomap** replaces direct distances with shortest paths through a neighborhood graph.
- **t-SNE** focuses strongly on local neighborhoods.
- **UMAP** builds a low-dimensional map from a neighborhood graph.

The first three example datasets have known classes, so color identifies the generated group. For **Swiss roll**, color follows position along the surface and should not be interpreted as a class.

The axes from different methods are not directly comparable. A visually separated map can be useful, but it does not prove that real groups exist.
