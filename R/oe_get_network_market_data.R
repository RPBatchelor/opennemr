#' Get network market data from OpenElectricity API
#'
#' @description
#' Retrieve market-related time series data for electricity networks from the
#' OpenElectricity API v4. This endpoint provides access to market metrics like
#' price, demand, and market value aggregated at the network or regional level.
#'
#' @param network_code Character. Network identifier. Valid values: "NEM", "WEM", "AEMO_ROOFTOP", "APVI". Required.
#' @param metrics Character vector. Metrics to retrieve. Valid values: "power", "energy", "price", "market_value", "demand", "demand_energy", "emissions", "renewable_proportion". See `oe_metrics` for details. Required.
#' @param interval Character. Time interval for data aggregation. Valid values: "5m", "1h", "1d", "7d", "1M", "3M", "season", "1y", "fy". Default: "5m".
#' @param date_start Character or POSIXct. Start date/time for data range. Format: "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS". Default: NULL (API default).
#' @param date_end Character or POSIXct. End date/time for data range. Format: "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS". Default: NULL (API default).
#' @param network_region Character. Filter by network region. Valid values: "NSW1", "QLD1", "SA1", "TAS1", "VIC1", "SNOWY1", "WEM". Default: NULL (all regions).
#' @param primary_grouping Character. Primary grouping for data aggregation. Valid values: "network", "network_region". Default: "network".
#' @param with_clerk Logical. Include clerk data in response. Default: TRUE.
#' @param api_key Character. OpenElectricity API key. If NULL, uses OPEN_ELECTRICITY_API_KEY environment variable. Default: NULL.
#'
#' @return Data frame with columns:
#' \describe{
#'   \item{datetime}{POSIXct timestamp for the data point with network timezone}
#'   \item{value}{Numeric value for the metric}
#'   \item{series_name}{Name of the data series}
#'   \item{network_code}{Network identifier}
#'   \item{metric}{Metric type}
#'   \item{unit}{Unit of measurement}
#'   \item{interval}{Time interval}
#' }
#'
#' @details
#' This function provides access to market-related data including prices, demand,
#' and market values. Unlike `oe_get_network_data()`, this endpoint can handle
#' multiple metrics in a single request.
#'
#' Common use cases:
#' - Price analysis and forecasting
#' - Demand patterns and trends
#' - Market value calculations
#' - Regional market comparisons
#'
#' @examples
#' \dontrun{
#' # Get price data for NEM
#' nem_prices <- oe_get_network_market_data(
#'   network_code = "NEM",
#'   metrics = "price",
#'   interval = "1h",
#'   date_start = "2024-12-01",
#'   date_end = "2024-12-02"
#' )
#'
#' # Get multiple market metrics
#' market_data <- oe_get_network_market_data(
#'   network_code = "NEM",
#'   metrics = c("price", "demand", "market_value"),
#'   interval = "1d",
#'   network_region = "VIC1"
#' )
#'
#' # Get demand and price for all NEM regions
#' regional_market <- oe_get_network_market_data(
#'   network_code = "NEM",
#'   metrics = c("demand", "price"),
#'   interval = "1h",
#'   primary_grouping = "network_region"
#' )
#' }
#'
#' @seealso
#' \code{\link{oe_get_network_data}} for generation/emissions data,
#' \code{\link{oe_get_facility_data}} for facility-level data
#'
#' @export
oe_get_network_market_data <- function(network_code,
                                        metrics,
                                        interval = "5m",
                                        date_start = NULL,
                                        date_end = NULL,
                                        network_region = NULL,
                                        primary_grouping = "network",
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

  # Validate network_region if provided
  if (!is.null(network_region)) {
    valid_regions <- oe_network_regions$region
    if (!network_region %in% valid_regions) {
      stop(sprintf(
        "Invalid network_region '%s'. Must be one of: %s",
        network_region,
        paste(valid_regions, collapse = ", ")
      ))
    }
  }

  # Validate primary_grouping
  valid_groupings <- c("network", "network_region")
  if (!primary_grouping %in% valid_groupings) {
    stop(sprintf(
      "Invalid primary_grouping '%s'. Must be one of: %s",
      primary_grouping,
      paste(valid_groupings, collapse = ", ")
    ))
  }


  # Build the required endpoint URL
  endpoint <- paste0(
    oe_endpoints$oe_api_base_url,
    oe_endpoints$oe_api_market_data,
    network_code
  )


  # Build query parameters
  query_params <- list(
    interval = interval,
    primary_grouping = primary_grouping,
    with_clerk = tolower(as.character(with_clerk))
  )

  # Add metrics (can be multiple)
  for (metric in metrics) {
    query_params <- c(query_params, list(metrics = metric))
  }

  # Add optional date parameters
  if (!is.null(date_start)) {
    query_params$date_start <- format_datetime(date_start)
  }

  if (!is.null(date_end)) {
    query_params$date_end <- format_datetime(date_end)
  }

  # Add optional network_region
  if (!is.null(network_region)) {
    query_params$network_region <- network_region
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

  # Convert to data frame using network data parser, passing grouping name for dynamic column naming
  df <- parse_network_data(
    content$data,
    primary_grouping_name = primary_grouping
  )

  return(df)
}
