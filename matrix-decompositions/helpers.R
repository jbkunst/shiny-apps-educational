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