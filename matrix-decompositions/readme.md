This app generates a small matrix \\(A\\) and shows how different decompositions rewrite it into simpler pieces.

Choose a decomposition, change the matrix size or structure, and generate a new matrix. The rendered result shows the factorization and the pieces used to rebuild or interpret \\(A\\).

**Matrix assumptions**:

Some decompositions do not require a square matrix. In this app, we use square real-valued matrices for simplicity.

Generated matrices are symmetric positive-definite, so the decompositions work reliably.

Random values use integers up to the selected maximum absolute value. The diagonal is adjusted automatically to keep the matrix positive-definite.

For PCA, the same matrix is interpreted as a covariance-like matrix so we can talk about variance explained by principal components.
