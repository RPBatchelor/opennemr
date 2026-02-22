#' Get network market data from OpenElectricity API
#'
#' @description
#' Retrieve market-related time series data for electricity networks from the
#' OpenElectricity API v4. This endpoint provides access to market metrics like
#' price, demand, and market value aggregated at the network or regional level.
#'
#' @param network_code Character. Network identifier. Valid values: "NEM", "WEM". Required.
#'   Note: "AEMO_ROOFTOP" and "APVI" are not supported by this endpoint (API returns 400).
#' @param metrics Character vector. Metrics to retrieve. Valid values: "power", "energy", "price", "demand", "demand_energy", "emissions", "renewable_proportion". See `oe_metrics` for details. Required.
#'   Note: "market_value" is listed in the API docs but returns a 400 error as of API v4.4.12 and is not supported.
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
#'   metrics = c("price", "demand"),
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

  # Validate network_code — only NEM and WEM are supported by this endpoint
  valid_networks <- c("NEM", "WEM")
  if (!network_code %in% valid_networks) {
    stop(glue::glue("Invalid network_code '{network_code}'. Must be one of: {paste(valid_networks, collapse = ', ')}. Note: AEMO_ROOFTOP and APVI are not supported by this endpoint."))
  }

  # Validate metrics (can be multiple)
  valid_metrics <- oe_metrics$metric
  invalid_metrics <- metrics[!metrics %in% valid_metrics]
  if (length(invalid_metrics) > 0) {
    stop(glue::glue("Invalid metric(s): {paste(invalid_metrics, collapse = ', ')}. Valid metrics are: {paste(valid_metrics, collapse = ', ')}"))
  }

  # Validate interval
  valid_intervals <- oe_intervals$interval
  if (!interval %in% valid_intervals) {
    stop(glue::glue("Invalid interval '{interval}'. Must be one of: {paste(valid_intervals, collapse = ', ')}"))
  }

  # Validate network_region if provided
  if (!is.null(network_region)) {
    valid_regions <- oe_network_regions$region
    if (!network_region %in% valid_regions) {
      stop(glue::glue("Invalid network_region '{network_region}'. Must be one of: {paste(valid_regions, collapse = ', ')}"))
    }
  }

  # Validate primary_grouping
  valid_primary_groupings <- oe_primary_groupings$primary_grouping
  if (!primary_grouping %in% valid_primary_groupings) {
    stop(glue::glue("Invalid primary_grouping '{primary_grouping}'. Must be one of: {paste(valid_primary_groupings, collapse = ', ')}"))
  }


  # Check date range against API limits and handle chunked requests if needed
  if (!is.null(date_start)) {
    limit_info <- check_date_range_limits(date_start, date_end, interval)
    if (limit_info$exceeds) {
      message(glue::glue("You have asked for a duration that exceeds the standard limit for the '{interval}' interval ({limit_info$max_days_desc}).
This will require {limit_info$n_chunks} separate API calls."))
      if (!interactive()) {
        stop("Date range exceeds API limit. Reduce the date range or make multiple requests manually.")
      }
      response <- readline("Would you like to proceed? (y/n): ")
      if (tolower(trimws(response)) != "y") {
        message("Request cancelled.")
        return(invisible(NULL))
      }
      message(glue::glue("Making {limit_info$n_chunks} API calls..."))
      results <- lapply(seq_along(limit_info$chunks), function(i) {
        chunk <- limit_info$chunks[[i]]
        message(glue::glue("  Call {i} of {limit_info$n_chunks}: {chunk$start} to {chunk$end}"))
        oe_get_network_market_data(
          network_code      = network_code,
          metrics           = metrics,
          interval          = interval,
          date_start        = chunk$start,
          date_end          = chunk$end,
          network_region    = network_region,
          primary_grouping  = primary_grouping,
          with_clerk        = with_clerk,
          api_key           = api_key
        )
      })
      return(do.call(rbind, results))
    }
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
    status_code <- httr::status_code(response)
    error_body  <- httr::content(response, "text", encoding = "UTF-8")
    stop(glue::glue("API request failed [{status_code}]: {error_body}"))
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
