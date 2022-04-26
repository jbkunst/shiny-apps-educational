matrix2latex <- function(matr) {
  
  apply(matr, 1, function(r) str_c(r, collapse = " & ")) %>% 
    str_c(collapse = "\\\\") %>% 
    str_c(
      "\\begin{pmatrix}",
      .,
      "\\end{pmatrix}"
    )
  
}
