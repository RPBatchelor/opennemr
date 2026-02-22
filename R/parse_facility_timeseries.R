#' Parse facility time series data from API response
#'
#' @description
#' Internal helper function that parses facility-level time series data from the
#' OpenElectricity API. This function extends `parse_network_data()` by extracting
#' the facility unit code from the series name using regex.
#'
#' @param data List from API response containing facility time series data
#'
#' @return Data frame with columns:
#' \describe{
#'   \item{datetime}{POSIXct timestamp with network timezone}
#'   \item{value}{Numeric value for the metric}
#'   \item{unit_code}{Facility unit code (e.g., "LYA1", "HVPS1")}
#'   \item{network_code}{Network identifier}
#'   \item{metric}{Metric type}
#'   \item{unit}{Unit of measurement (MW, MWh, etc.)}
#'   \item{interval}{Time interval}
#' }
#'
#' @details
#' This parser first calls `parse_network_data()` to handle the basic data structure
#' and datetime conversion. It then processes the `series_name` column which contains
#' values like "power_LYA1" where the part after the underscore is the facility unit code.
#'
#' The function uses stringr to extract everything after the last underscore as the unit_code,
#' then removes the redundant series_name column.
#'
#' @examples
#' \dontrun{
#' # Internal use only - called by oe_get_facility_data()
#' df <- parse_facility_timeseries(api_response$data)
#' }
#'
#' @seealso \code{\link{parse_network_data}} for the base parser
#'
#' @keywords internal
parse_facility_timeseries <- function(data) {

  # First, use the standard network data parser
  df <- parse_network_data(data)

  # If empty, return early
  if (nrow(df) == 0) {
    return(df)
  }

  # Use dplyr and stringr to extract unit code from series_name
  # Format is typically: "metric_UNITCODE" (e.g., "power_LYA1")
  # Extract everything after the last underscore
  df <- df |>
    dplyr::mutate(
      unit_code = stringr::str_extract(series_name, "(?<=_)[^_]+$")
    ) |>
    dplyr::select(
      datetime,
      value,
      unit_code,
      network_code,
      metric,
      unit,
      interval
    )

  return(df)
}
