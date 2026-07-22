## How it works

The app builds a feature matrix from the maintained PokeAPI tables. Numeric features include height, weight, base experience, and the six battle stats. Pokémon types and egg groups are added as indicator variables.

Choose a projection method and change its main parameters:

- **PCA** gives a fast linear baseline.
- **t-SNE** exposes perplexity and iteration count.
- **UMAP** exposes neighborhood size and minimum distance.

Click **Run projection** to recompute the two-dimensional coordinates. The chart uses the regular PokeAPI sprite as the point marker. Hover a Pokémon to see its official artwork, types, generation, size, and battle stats.

The coordinates are exploratory rather than a distance metric to interpret literally. They are useful for spotting groups, evolution families, unusual type combinations, and differences between projection methods.

### Data

Data: [PokeAPI/pokeapi](https://github.com/PokeAPI/pokeapi)  
Sprites and artwork: [PokeAPI/sprites](https://github.com/PokeAPI/sprites)
