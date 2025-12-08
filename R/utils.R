#' @noRd
dummy <- function() {
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
  # If it's a character, parse and format it
  dt_char <- as.character(dt)

  # Remove any 'Z' or timezone info
  dt_char <- gsub("Z$", "", dt_char)  # Remove trailing Z
  dt_char <- gsub("[+-]\\d{2}:\\d{2}$", "", dt_char)  # Remove timezone offset

  # If it's just a date (YYYY-MM-DD), add time component
  if (grepl("^\\d{4}-\\d{2}-\\d{2}$", dt_char)) {
    dt_char <- paste0(dt_char, "T00:00:00")
  }

  return(dt_char)
}


