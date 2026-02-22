#' Split a date range into chunks of a maximum number of days
#'
#' @param date_start Start date (Date or character in YYYY-MM-DD format)
#' @param date_end End date (Date or character in YYYY-MM-DD format)
#' @param max_days Maximum number of days per chunk
#'
#' @return List of lists, each with $start and $end as "YYYY-MM-DDTHH:MM:SS" strings
#'
#' @keywords internal
#' @noRd
split_date_range <- function(date_start, date_end, max_days) {
  start <- as.Date(substr(as.character(date_start), 1, 10))
  end   <- as.Date(substr(as.character(date_end),   1, 10))

  chunks <- list()
  chunk_start <- start

  while (chunk_start < end) {
    chunk_end <- min(chunk_start + max_days, end)
    chunks <- c(chunks, list(list(
      start = format(chunk_start, "%Y-%m-%dT00:00:00"),
      end   = format(chunk_end,   "%Y-%m-%dT00:00:00")
    )))
    chunk_start <- chunk_end
  }

  return(chunks)
}


#' Check whether a date range exceeds the API limit for a given interval
#'
#' @param date_start Start date (character or POSIXct). If NULL, returns no limit exceeded.
#' @param date_end End date (character or POSIXct). If NULL, today's date is used.
#' @param interval Interval string (e.g. "5m", "1h", "1d")
#'
#' @return A list with:
#'   \item{exceeds}{Logical. TRUE if the range exceeds the limit.}
#'   \item{total_days}{Total days in the requested range (if exceeds).}
#'   \item{max_days}{The maximum allowed days for this interval (if exceeds).}
#'   \item{max_days_desc}{Human-readable limit description (if exceeds).}
#'   \item{n_chunks}{Number of API calls required (if exceeds).}
#'   \item{chunks}{List of date range pairs to use for chunked calls (if exceeds).}
#'
#' @keywords internal
#' @noRd
check_date_range_limits <- function(date_start, date_end, interval) {
  if (is.null(date_start)) return(list(exceeds = FALSE))

  limit_row <- oe_data_limits[oe_data_limits$interval == interval, ]
  if (nrow(limit_row) == 0) return(list(exceeds = FALSE))

  max_days      <- limit_row$max_days
  max_days_desc <- limit_row$max_days_desc

  start      <- as.Date(substr(as.character(date_start), 1, 10))
  end        <- if (is.null(date_end)) Sys.Date() else as.Date(substr(as.character(date_end), 1, 10))
  total_days <- as.numeric(end - start)

  if (total_days <= max_days) return(list(exceeds = FALSE))

  n_chunks <- ceiling(total_days / max_days)
  chunks   <- split_date_range(start, end, max_days)

  return(list(
    exceeds       = TRUE,
    total_days    = total_days,
    max_days      = max_days,
    max_days_desc = max_days_desc,
    n_chunks      = n_chunks,
    chunks        = chunks
  ))
}
