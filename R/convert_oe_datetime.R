#' Convert OpenElectricity API datetime strings to POSIXct
#'
#' @description
#' Converts datetime strings returned by the OpenElectricity API into R POSIXct
#' objects with proper timezone handling. Handles ISO 8601 format with timezone offsets.
#'
#' @param datetime_string Character vector of datetime strings from the API.
#'   Format: "2025-12-04T19:45:00+10:00" (ISO 8601 with timezone offset).
#' @param network_code Character. Network identifier (e.g., "NEM", "WEM").
#'   Used to set the timezone of the returned POSIXct object.
#'   If NULL, keeps the timezone from the datetime string offset.
#'
#' @return POSIXct vector with proper timezone attributes.
#'
#' @details
#' The function parses ISO 8601 datetime strings with timezone offsets and converts
#' them to POSIXct objects. If a network_code is provided, the times are converted
#' to that network's timezone.
#'
#' Network timezones (fixed offsets per API documentation):
#' - NEM: Etc/GMT-10 (UTC+10, fixed — NEM market time never adjusts for DST)
#' - WEM: Australia/Perth (UTC+8, no DST)
#' - AEMO_ROOFTOP: Etc/GMT-10 (UTC+10, fixed)
#' - APVI: Etc/GMT-10 (UTC+10, fixed)
#'
#' @examples
#' \dontrun{
#' # Basic conversion
#' convert_oe_datetime("2025-12-04T19:45:00+10:00")
#'
#' # With network timezone
#' convert_oe_datetime("2025-12-04T19:45:00+10:00", network_code = "NEM")
#'
#' # Vectorized
#' datetimes <- c("2025-12-04T19:45:00+10:00", "2025-12-04T19:50:00+10:00")
#' convert_oe_datetime(datetimes, network_code = "NEM")
#' }
#'
#' @keywords internal
convert_oe_datetime <- function(datetime_string, network_code = NULL) {

  # Handle empty input
  if (length(datetime_string) == 0) {
    return(as.POSIXct(character(0)))
  }

  # Handle all NA input - return NA vector of same length
  if (all(is.na(datetime_string))) {
    result <- as.POSIXct(rep(NA_character_, length(datetime_string)))
    return(result)
  }

  # Map network codes to R timezone names.
  # NEM, AEMO_ROOFTOP, and APVI use a fixed UTC+10 offset (no DST).
  # The NEM settles on market time which is always UTC+10, never UTC+11.
  # "Etc/GMT-10" is the POSIX fixed-offset timezone for UTC+10 (note: POSIX
  # sign convention is inverted, so Etc/GMT-10 = UTC+10).
  # WEM uses Australia/Perth which is always UTC+8 with no DST.
  network_tz_map <- c(
    "NEM"          = "Etc/GMT-10",
    "WEM"          = "Australia/Perth",
    "AEMO_ROOFTOP" = "Etc/GMT-10",
    "APVI"         = "Etc/GMT-10"
  )

  # Parse the datetime strings with timezone offset
  # Format: "2025-12-04T19:45:00+10:00"
  # The %z format code handles +10:00 style offsets in newer R versions
  # For compatibility, we may need to remove the colon
  datetime_clean <- gsub("([+-]\\d{2}):(\\d{2})$", "\\1\\2", datetime_string)

  # Parse as POSIXct
  dt <- as.POSIXct(datetime_clean, format = "%Y-%m-%dT%H:%M:%S%z", tz = "UTC")

  # If network_code is provided, convert to that timezone
  if (!is.null(network_code) && network_code %in% names(network_tz_map)) {
    # Use unname() to remove the name attribute from the vector lookup
    target_tz <- unname(network_tz_map[network_code])
    dt <- as.POSIXct(format(dt, tz = target_tz), tz = target_tz)
  }

  return(dt)
}
