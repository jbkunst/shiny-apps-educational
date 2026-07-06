matrix2latex <- function(matr) {

  out <- apply(matr, 1, function(r) str_c(r, collapse = " & ")) |>
    str_c(collapse = "\\\\")

  out <- str_c(
    "\\begin{pmatrix}",
    out,
    "\\end{pmatrix}"
  )

  out

}

matrix_kind_label <- function(kind) {

  switch(
    kind,
    dense_spd = "dense symmetric positive-definite",
    sparse_spd = "sparse symmetric positive-definite",
    banded_spd = "banded symmetric positive-definite",
    diagonal_spd = "diagonal positive-definite",
    "symmetric positive-definite"
  )

}

label_with_info <- function(label, tooltip_text) {
  trigger <- tags$span(
    class = "info-tooltip",
    title = tooltip_text,
    tabindex = "0",
    `aria-label` = tooltip_text,
    icon("info-circle")
  )

  tags$span(
    class = "label-with-info",
    tags$strong(label),
    tooltip(
      trigger,
      tooltip_text,
      placement = "right",
      options = list(trigger = "hover focus")
    )
  )

}

generate_spd_matrix <- function(n, kind = "dense_spd", coefficient_max = 4) {

  n <- as.integer(n)
  coefficient_max <- as.integer(coefficient_max)

  mat <- matrix(0, nrow = n, ncol = n)

  if (kind == "diagonal_spd") {

    diag(mat) <- sample(1:coefficient_max, n, replace = TRUE)

    return(mat)

  }

  if (kind == "banded_spd") {

    values <- sample(
      c(-coefficient_max:-1, 1:coefficient_max),
      n - 1,
      replace = TRUE
    )

    mat[cbind(2:n, 1:(n - 1))] <- values
    mat[cbind(1:(n - 1), 2:n)] <- values

  } else {

    lower_index <- lower.tri(mat)
    values <- sample(
      c(-coefficient_max:-1, 1:coefficient_max),
      sum(lower_index),
      replace = TRUE
    )

    if (kind == "sparse_spd") {
      values <- values * rbinom(sum(lower_index), 1, 0.4)
    }

    mat[lower_index] <- values
    mat <- mat + t(mat)

  }

  diag(mat) <- rowSums(abs(mat)) + sample(1:coefficient_max, n, replace = TRUE)

  mat

}
