A decision tree splits the plane into simple regions. Each split chooses a rule that separates the response classes as clearly as possible.

The `alpha` control changes how strict the tree is before accepting a split. Smaller values make the tree more conservative; larger values allow more splits.

Depth sets the maximum complexity, but alpha decides whether each split is worth making. Only splits with p-values below alpha are accepted.

Turn on split p-values when you want to see why a split was accepted. Use noise and depth to explore underfitting, overfitting, and decision boundaries.
