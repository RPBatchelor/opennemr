#' Get facility time series data from OpenElectricity API
#'
#' @description
#' Retrieve time series data for specific electricity generation facilities from the
#' OpenElectricity API v4. This function provides access to facility-level metrics like
#' power output, energy generation, market value, and emissions for individual facilities.
#'
#' @param network_code Character. Network identifier. Valid values: "NEM", "WEM", "AEMO_ROOFTOP", "APVI". Required.
#' @param metrics Character vector. Metrics to retrieve. Valid values: "power", "energy", "price", "market_value", "demand", "demand_energy", "emissions", "renewable_proportion". See `oe_metrics` for details. Required.
#' @param facility_code Character vector. Facility code(s) to get data for. If NULL, returns data for all facilities in the network. Default: NULL.
#' @param interval Character. Time interval for data aggregation. Valid values: "5m", "1h", "1d", "7d", "1M", "3M", "season", "1y", "fy". Default: "5m".
#' @param date_start Character or POSIXct. Start date/time for data range. Format: "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS". Default: NULL (API default).
#' @param date_end Character or POSIXct. End date/time for data range. Format: "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS". Default: NULL (API default).
#' @param with_clerk Logical. Include clerk data in response. Default: TRUE.
#' @param api_key Character. OpenElectricity API key. If NULL, uses OPEN_ELECTRICITY_API_KEY environment variable. Default: NULL.
#'
#' @return Data frame with columns:
#' \describe{
#'   \item{datetime}{POSIXct timestamp for the data point with network timezone}
#'   \item{value}{Numeric value for the metric}
#'   \item{series_name}{Name of the data series (typically facility code and metric)}
#'   \item{network_code}{Network identifier}
#'   \item{metric}{Metric type}
#'   \item{unit}{Unit of measurement}
#'   \item{interval}{Time interval}
#' }
#'
#' @details
#' This function retrieves time series data for individual facilities, allowing detailed
#' analysis of specific generation assets. Use `oe_get_facilities()` to find facility codes.
#'
#' Unlike `oe_get_network_data()`, this endpoint can handle multiple metrics in a single
#' request, making it more efficient when you need multiple data types for the same facilities.
#'
#' @examples
#' \dontrun{
#' # Get power data for a specific facility
#' facility_power <- oe_get_facility_data(
#'   network_code = "NEM",
#'   metrics = "power",
#'   facility_code = "LOYYANGA",
#'   interval = "1h",
#'   date_start = "2024-12-01",
#'   date_end = "2024-12-02"
#' )
#'
#' # Get multiple metrics for a facility
#' facility_data <- oe_get_facility_data(
#'   network_code = "NEM",
#'   metrics = c("power", "emissions"),
#'   facility_code = "LOYYANGA",
#'   interval = "1d"
#' )
#'
#' # Get data for multiple facilities
#' facilities_power <- oe_get_facility_data(
#'   network_code = "NEM",
#'   metrics = "power",
#'   facility_code = c("LOYYANGA", "HVPS"),
#'   interval = "1h"
#' )
#' }
#'
#' @seealso
#' \code{\link{oe_get_facilities}} to find facility codes,
#' \code{\link{oe_get_network_data}} for network-level aggregated data
#'
#' @export
oe_get_facility_data <- function(network_code,
                                  metrics,
                                  facility_code = NULL,
                                  interval = "5m",
                                  date_start = NULL,
                                  date_end = NULL,
                                  with_clerk = TRUE,
                                  api_key = NULL) {

  # Validate required inputs
  if (missing(network_code) || is.null(network_code)) {
    stop("network_code is required")
  }

  if (missing(metrics) || is.null(metrics)) {
    stop("metrics is required")
  }

  if (is.null(api_key)) {
    api_key <- oe_get_api()
  }


  # Validate parameter values against reference data

  # Validate network_code
  valid_networks <- oe_network_list$network_name
  if (!network_code %in% valid_networks) {
    stop(sprintf(
      "Invalid network_code '%s'. Must be one of: %s",
      network_code,
      paste(valid_networks, collapse = ", ")
    ))
  }

  # Validate metrics (can be multiple)
  valid_metrics <- oe_metrics$metric
  invalid_metrics <- metrics[!metrics %in% valid_metrics]
  if (length(invalid_metrics) > 0) {
    stop(sprintf(
      "Invalid metric(s): %s. Valid metrics are: %s",
      paste(invalid_metrics, collapse = ", "),
      paste(valid_metrics, collapse = ", ")
    ))
  }

  # Validate interval
  valid_intervals <- oe_intervals$interval
  if (!interval %in% valid_intervals) {
    stop(sprintf(
      "Invalid interval '%s'. Must be one of: %s",
      interval,
      paste(valid_intervals, collapse = ", ")
    ))
  }


  # Build the required endpoint URL
  endpoint <- paste0(
    oe_endpoints$oe_api_base_url,
    oe_endpoints$oe_api_facility_data,
    network_code
  )


  # Build query parameters
  query_params <- list(
    interval = interval,
    with_clerk = tolower(as.character(with_clerk))
  )

  # Add metrics (can be multiple)
  for (metric in metrics) {
    query_params <- c(query_params, list(metrics = metric))
  }

  # Add facility_code(s) if provided
  if (!is.null(facility_code)) {
    for (code in facility_code) {
      query_params <- c(query_params, list(facility_code = code))
    }
  }

  # Add optional date parameters
  if (!is.null(date_start)) {
    query_params$date_start <- format_datetime(date_start)
  }

  if (!is.null(date_end)) {
    query_params$date_end <- format_datetime(date_end)
  }


  # Make API request
  response <- httr::GET(
    url = endpoint,
    query = query_params,
    httr::add_headers(
      "Authorization" = paste("Bearer", api_key),
      "Content-Type" = "application/json"
    )
  )

  # Check response status
  if (httr::http_error(response)) {
    stop(
      sprintf(
        "API request failed [%s]: %s",
        httr::status_code(response),
        httr::content(response, "text", encoding = "UTF-8")
      )
    )
  }

  # Parse response
  content <- httr::content(response, as = "parsed", encoding = "UTF-8")

  # Check if request was successful
  if (!isTRUE(content$success)) {
    stop(paste("API error:", content$error))
  }

  # Convert to data frame using the facility timeseries parser
  # This extracts unit codes from series names and returns clean dataframe
  df <- parse_facility_timeseries(content$data)

  return(df)
}
