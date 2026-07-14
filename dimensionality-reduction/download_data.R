set.seed(20260713)

data_dir <- here::here("dimensionality-reduction", "data")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

n_mnist   <- 10000
n_fashion <- 10000
n_mammoth <- 10000


# MNIST digits -------------------------------------------------------------
if (!requireNamespace("klassets", quietly = TRUE)) {
  stop("Install klassets before preparing MNIST data.", call. = FALSE)
}

data("mnist_train", package = "klassets")

id    <- sample(seq_len(nrow(mnist_train)), size = min(n_mnist, nrow(mnist_train)))
mnist <- mnist_train[id, , drop = FALSE]

mnist_x <- as.matrix(mnist[, setdiff(names(mnist), "label"), drop = FALSE]) / 255
mnist_x <- round(mnist_x, 3)

saveRDS(
  list(x = mnist_x, label = factor(mnist$label), source = "klassets::mnist_train"),
  file.path(data_dir, "mnist.rds")
)

# Mammoth point cloud ------------------------------------------------------
library(jsonlite)
library(tibble)

url <- paste0("https://raw.githubusercontent.com/", "PAIR-code/understanding-umap/master/", "raw_data/mammoth_umap.json")
obj <- fromJSON(url)

mammoth <- tibble(
  x = obj[["3d"]][, 1],
  y = obj[["3d"]][, 2],
  z = obj[["3d"]][, 3],
  region = factor(obj$labels)
)

saveRDS(
  list(
    x = round(as.matrix(mammoth[,c("x", "y", "z")]), 3),
    label = mammoth$region,
    source = "PAIR-code/understanding-umap"
  ),
  file.path(data_dir, "mammoth.rds")
)

# Fashion-MNIST ------------------------------------------------------------
fashion_urls <- c(
  images = "http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/train-images-idx3-ubyte.gz",
  labels = "http://fashion-mnist.s3-website.eu-central-1.amazonaws.com/train-labels-idx1-ubyte.gz"
)

fashion_files <- file.path(tempdir(), basename(fashion_urls))

download.file(fashion_urls[["images"]], fashion_files[[1]], mode = "wb", quiet = TRUE)
download.file(fashion_urls[["labels"]], fashion_files[[2]], mode = "wb", quiet = TRUE)

read_idx_integer <- function(con) {
  readBin(con, integer(), size = 4, n = 1, endian = "big")
}

read_idx_labels <- function(file) {
  con <- gzfile(file, "rb")
  on.exit(close(con), add = TRUE)

  read_idx_integer(con)
  n <- read_idx_integer(con)

  readBin(con, integer(), size = 1, n = n, signed = FALSE)
}

read_idx_images <- function(file) {
  con <- gzfile(file, "rb")
  on.exit(close(con), add = TRUE)

  read_idx_integer(con)
  n <- read_idx_integer(con)
  rows <- read_idx_integer(con)
  cols <- read_idx_integer(con)

  pixels <- readBin(con, integer(), size = 1, n = n * rows * cols, signed = FALSE)
  matrix(pixels, nrow = n, byrow = TRUE) / 255
}

fashion_labels <- read_idx_labels(fashion_files[[2]])
fashion_images <- read_idx_images(fashion_files[[1]])

fashion_names <- c(
  "T-shirt/top",
  "Trouser",
  "Pullover",
  "Dress",
  "Coat",
  "Sandal",
  "Shirt",
  "Sneaker",
  "Bag",
  "Ankle boot"
)

id <- sample(seq_len(nrow(fashion_images)), size = min(n_fashion, nrow(fashion_images)))

saveRDS(
  list(
    x = round(fashion_images[id, , drop = FALSE], 3),
    label = factor(fashion_names[fashion_labels[id] + 1], levels = fashion_names),
    source = "Fashion-MNIST"
  ),
  file.path(data_dir, "fashion-mnist.rds")
)

# Summary -----------------------------------------------------------------
message("Saved real datasets in: ", normalizePath(data_dir, winslash = "/"))
