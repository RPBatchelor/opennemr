#' Repeat dataframe n times
#'
#' @param df A dataframe object
#' @param n The number of times to repeat the dataframe rows
#'
#' @return A dataframe with original rows repeated n times
#' @export
#'


repeat_df_rows <- function(df, n) {
  return(do.call(rbind, replicate(n, df, simplify = FALSE)))
}
