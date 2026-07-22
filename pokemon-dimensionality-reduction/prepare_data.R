# Pokémon data -------------------------------------------------------------

pokemon_type_colors <- c(
  normal = "#A8A77A", fire = "#EE8130", water = "#6390F0",
  electric = "#F7D02C", grass = "#7AC74C", ice = "#96D9D6",
  fighting = "#C22E28", poison = "#A33EA1", ground = "#E2BF65",
  flying = "#A98FF3", psychic = "#F95587", bug = "#A6B91A",
  rock = "#B6A136", ghost = "#735797", dragon = "#6F35FC",
  dark = "#705746", steel = "#B7B7CE", fairy = "#D685AD"
)

pokeapi_csv <- function(file, ref = "master") {
  url <- paste0(
    "https://raw.githubusercontent.com/PokeAPI/pokeapi/",
    ref,
    "/data/v2/csv/",
    file
  )

  readr::read_csv(url, show_col_types = FALSE)
}

scale_numeric_features <- function(data) {
  data <- as.data.frame(data)

  data[] <- lapply(data, function(x) {
    x <- as.numeric(x)
    replacement <- stats::median(x, na.rm = TRUE)

    if (!is.finite(replacement)) {
      replacement <- 0
    }

    x[is.na(x)] <- replacement
    x
  })

  x <- as.matrix(data)
  center <- colMeans(x)
  spread <- apply(x, 2, stats::sd)
  spread[!is.finite(spread) | spread == 0] <- 1

  x <- sweep(x, 2, center, FUN = "-")
  sweep(x, 2, spread, FUN = "/")
}

pokemon_feature_matrix <- function(data) {
  numeric_features <- data |>
    dplyr::select(
      height, weight, base_experience,
      hp, attack, defense, special_attack, special_defense, speed,
      capture_rate, base_happiness, hatch_counter, gender_rate,
      is_baby, is_legendary, is_mythical,
      has_gender_differences, forms_switchable
    ) |>
    scale_numeric_features()

  categorical_data <- data |>
    dplyr::transmute(
      type_1 = factor(type_1),
      type_2 = factor(type_2),
      egg_group_1 = factor(egg_group_1),
      egg_group_2 = factor(egg_group_2),
      growth_rate = factor(growth_rate),
      body_color = factor(body_color),
      body_shape = factor(body_shape),
      habitat = factor(habitat)
    )

  categorical_features <- stats::model.matrix(
    ~ type_1 + type_2 + egg_group_1 + egg_group_2 +
      growth_rate + body_color + body_shape + habitat - 1,
    data = categorical_data
  )

  features <- cbind(numeric_features, categorical_features)
  storage.mode(features) <- "double"
  features
}

prepare_pokemon_data <- function(cache_file = NULL, refresh = FALSE) {
  if (
    !is.null(cache_file) &&
      file.exists(cache_file) &&
      !isTRUE(refresh)
  ) {
    return(readRDS(cache_file))
  }

  pokemon <- pokeapi_csv("pokemon.csv") |>
    dplyr::filter(is_default == 1) |>
    dplyr::transmute(
      id,
      species_id,
      pokemon = identifier,
      height,
      weight,
      base_experience
    )

  stats <- pokeapi_csv("stats.csv") |>
    dplyr::transmute(
      stat_id = id,
      stat = stringr::str_replace_all(identifier, "-", "_")
    ) |>
    dplyr::right_join(
      pokeapi_csv("pokemon_stats.csv") |>
        dplyr::select(pokemon_id, stat_id, base_stat),
      by = "stat_id"
    ) |>
    dplyr::select(pokemon_id, stat, base_stat) |>
    tidyr::pivot_wider(names_from = stat, values_from = base_stat) |>
    dplyr::rename(id = pokemon_id)

  types <- pokeapi_csv("types.csv") |>
    dplyr::transmute(type_id = id, type = identifier) |>
    dplyr::right_join(
      pokeapi_csv("pokemon_types.csv") |>
        dplyr::select(pokemon_id, type_id, slot),
      by = "type_id"
    ) |>
    dplyr::mutate(slot = paste0("type_", slot)) |>
    dplyr::select(pokemon_id, slot, type) |>
    tidyr::pivot_wider(names_from = slot, values_from = type) |>
    dplyr::rename(id = pokemon_id)

  egg_groups <- pokeapi_csv("egg_groups.csv") |>
    dplyr::transmute(egg_group_id = id, egg_group = identifier) |>
    dplyr::right_join(
      pokeapi_csv("pokemon_egg_groups.csv") |>
        dplyr::select(species_id, egg_group_id),
      by = "egg_group_id"
    ) |>
    dplyr::group_by(species_id) |>
    dplyr::mutate(slot = paste0("egg_group_", dplyr::row_number())) |>
    dplyr::ungroup() |>
    dplyr::select(species_id, slot, egg_group) |>
    tidyr::pivot_wider(names_from = slot, values_from = egg_group)

  generations <- pokeapi_csv("generations.csv") |>
    dplyr::transmute(generation_id = id, generation = identifier)

  growth_rates <- pokeapi_csv("growth_rates.csv") |>
    dplyr::transmute(growth_rate_id = id, growth_rate = identifier)

  colors <- pokeapi_csv("pokemon_colors.csv") |>
    dplyr::transmute(color_id = id, body_color = identifier)

  shapes <- pokeapi_csv("pokemon_shapes.csv") |>
    dplyr::transmute(shape_id = id, body_shape = identifier)

  habitats <- pokeapi_csv("pokemon_habitats.csv") |>
    dplyr::transmute(habitat_id = id, habitat = identifier)

  species <- pokeapi_csv("pokemon_species.csv") |>
    dplyr::select(
      id, generation_id, evolves_from_species_id, evolution_chain_id,
      color_id, shape_id, habitat_id, gender_rate, capture_rate,
      base_happiness, is_baby, hatch_counter, has_gender_differences,
      growth_rate_id, forms_switchable, is_legendary, is_mythical
    ) |>
    dplyr::rename(species_id = id) |>
    dplyr::left_join(generations, by = "generation_id") |>
    dplyr::left_join(growth_rates, by = "growth_rate_id") |>
    dplyr::left_join(colors, by = "color_id") |>
    dplyr::left_join(shapes, by = "shape_id") |>
    dplyr::left_join(habitats, by = "habitat_id")

  data <- pokemon |>
    dplyr::left_join(types, by = "id") |>
    dplyr::left_join(stats, by = "id") |>
    dplyr::left_join(egg_groups, by = "species_id") |>
    dplyr::left_join(species, by = "species_id") |>
    dplyr::mutate(
      type_2 = tidyr::replace_na(type_2, "none"),
      egg_group_1 = tidyr::replace_na(egg_group_1, "none"),
      egg_group_2 = tidyr::replace_na(egg_group_2, "none"),
      growth_rate = tidyr::replace_na(growth_rate, "unknown"),
      body_color = tidyr::replace_na(body_color, "unknown"),
      body_shape = tidyr::replace_na(body_shape, "unknown"),
      habitat = tidyr::replace_na(habitat, "unknown"),
      generation = stringr::str_to_upper(generation),
      type_color = unname(pokemon_type_colors[type_1]),
      sprite_url = paste0(
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/",
        id,
        ".png"
      ),
      artwork_url = paste0(
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/",
        id,
        ".png"
      )
    ) |>
    dplyr::arrange(id)

  result <- list(
    data = data,
    x = pokemon_feature_matrix(data),
    feature_names = colnames(pokemon_feature_matrix(data)),
    source = "PokeAPI/pokeapi + PokeAPI/sprites"
  )

  if (!is.null(cache_file)) {
    dir.create(dirname(cache_file), recursive = TRUE, showWarnings = FALSE)
    try(saveRDS(result, cache_file), silent = TRUE)
  }

  result
}
