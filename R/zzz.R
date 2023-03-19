# Repeat a dataframe n times

#' Title
#'
#' @param df
#' @param n
#'
#' @return
#' @export
#'
#' @examples
repeat_df_rows <- function(df, n) {
  return(do.call(rbind, replicate(n, df, simplify = FALSE)))
}
