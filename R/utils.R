#' @noRd
dummy <- function() {
  assertthat::assert_that
  janitor::clean_names
  stringr::str_extract
  tibble::tibble
}


#' @noRd
repeat_df_rows <- function(df, n) {
  return(do.call(rbind, replicate(n, df, simplify = FALSE)))
}
