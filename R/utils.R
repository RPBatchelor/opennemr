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



#' Helper function to format datetime for API
#' @param dt Character or POSIXct datetime
#' @return Character in ISO 8601 format without timezone
#' @keywords internal
format_datetime <- function(dt) {
  if (inherits(dt, "POSIXct") || inherits(dt, "POSIXlt")) {
    # Remove timezone - API wants timezone-naive format
    return(format(dt, "%Y-%m-%dT%H:%M:%S"))
  }
  # If it's a character, remove any 'Z' or timezone info
  dt_char <- as.character(dt)
  dt_char <- gsub("Z$", "", dt_char)  # Remove trailing Z
  dt_char <- gsub("[+-]\\d{2}:\\d{2}$", "", dt_char)  # Remove timezone offset
  return(dt_char)
}


