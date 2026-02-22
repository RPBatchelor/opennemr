#' Get network time series data from OpenElectricity API
#'
#' @description
#' Retrieve time series electricity data for a specific network from the
#' OpenElectricity API v4. This function provides access to metrics like power,
#' energy, price, emissions, and more, aggregated by network, region, or fuel technology.
#'
#' @param network_code Character. Network identifier. Valid values: "NEM", "WEM". Required.
#'   Note: "AEMO_ROOFTOP" and "APVI" are not supported by this endpoint (API returns 400).
#' @param metrics Character. Metric to retrieve. Currently only single metrics are supported. Valid values: "power", "energy", "price", "market_value", "demand", "demand_energy", "emissions", "renewable_proportion". See `oe_metrics` for details. Required.
#' @param interval Character. Time interval for data aggregation. Valid values: "5m", "1h", "1d", "7d", "1M", "3M", "season", "1y", "fy". Default: "5m".
#' @param date_start Character or POSIXct. Start date/time for data range. Format: "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS". Default: NULL (API default).
#' @param date_end Character or POSIXct. End date/time for data range. Format: "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS". Default: NULL (API default).
#' @param network_region Character. Filter by network region. Valid values: "NSW1", "QLD1", "SA1", "TAS1", "VIC1", "SNOWY1", "WEM". Default: NULL (all regions).
#' @param fueltech Character. Filter by fuel technology. See `oe_fueltechs` for valid values. Default: NULL (all fueltechs).
#' @param fueltech_group Character. Filter by fuel technology group. See `oe_fueltech_groups` for valid values. Default: NULL (all groups).
#' @param primary_grouping Character. Primary grouping for data aggregation. Default: "network".
#' @param secondary_grouping Character. Secondary grouping for data aggregation. Default: NULL.
#' @param with_clerk Logical. Include clerk data in response. Default: TRUE.
#' @param api_key Character. OpenElectricity API key. If NULL, uses OPEN_ELECTRICITY_API_KEY environment variable. Default: NULL.
#'
#' @return Data frame with columns:
#' \describe{
#'   \item{datetime}{Timestamp for the data point}
#'   \item{value}{Numeric value for the metric}
#'   \item{series_name}{Name of the data series}
#'   \item{network_code}{Network identifier}
#'   \item{metric}{Metric type}
#'   \item{unit}{Unit of measurement}
#'   \item{interval}{Time interval}
#' }
#'
#' @details
#' **Current Limitation:** This function currently only supports single metric queries.
#' The API v4 returns 500 errors when multiple metrics are requested simultaneously.
#' This limitation is documented for future enhancement.
#'
#' @examples
#' \dontrun{
#' # Get hourly energy data for NEM
#' nem_energy <- oe_get_network_data(
#'   network_code = "NEM",
#'   metrics = "energy",
#'   interval = "1h",
#'   date_start = "2024-12-01",
#'   date_end = "2024-12-02"
#' )
#'
#' # Get power data for Victoria only
#' vic_power <- oe_get_network_data(
#'   network_code = "NEM",
#'   metrics = "power",
#'   interval = "5m",
#'   network_region = "VIC1"
#' )
#'
#' # Get emissions data for coal generation
#' coal_emissions <- oe_get_network_data(
#'   network_code = "NEM",
#'   metrics = "emissions",
#'   interval = "1d",
#'   fueltech_group = "coal"
#' )
#' }
#'
#' @export
oe_get_network_data <- function(network_code,
                                metrics,
                                interval = "5m",
                                date_start = NULL,
                                date_end = NULL,
                                network_region = NULL,
                                fueltech = NULL,
                                fueltech_group = NULL,
                                primary_grouping = "network",
                                secondary_grouping = NULL,
                                with_clerk = TRUE,
                                api_key = NULL
                                ){

  # Validate required inputs and dependencies
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

  # TODO: Add support for multiple metrics
  # Currently the API v4 returns 500 errors when multiple metrics are requested
  # For now, only allow single metric queries
  if (length(metrics) > 1) {
    stop("Currently only single metric queries are supported. Please provide one metric at a time.")
  }

  # Validate metrics
  valid_metrics <- oe_metrics$metric
  if (!metrics %in% valid_metrics) {
    stop(glue::glue("Invalid metric '{metrics}'. Valid metrics are: {paste(valid_metrics, collapse = ', ')}"))
  }

  # Check metric is supported by this endpoint
  if (!oe_metrics$api_working[oe_metrics$metric == metrics]) {
    working_metrics <- oe_metrics$metric[oe_metrics$api_working]
    stop(glue::glue(
      "Metric '{metrics}' is not supported by oe_get_network_data() (returns a 400 error from the API). ",
      "Supported metrics are: {paste(working_metrics, collapse = ', ')}. ",
      "For price and demand metrics, use oe_get_network_market_data() instead."
    ))
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

  # Validate fueltech if provided
  if (!is.null(fueltech)) {
    valid_fueltechs <- oe_fueltechs$fueltech
    if (!fueltech %in% valid_fueltechs) {
      stop(glue::glue("Invalid fueltech '{fueltech}'. Must be one of: {paste(valid_fueltechs, collapse = ', ')}"))
    }
  }

  # Validate fueltech_group if provided
  if (!is.null(fueltech_group)) {
    valid_fueltech_groups <- oe_fueltech_groups$fueltech_group
    if (!fueltech_group %in% valid_fueltech_groups) {
      stop(glue::glue("Invalid fueltech_group '{fueltech_group}'. Must be one of: {paste(valid_fueltech_groups, collapse = ', ')}"))
    }
  }

  # Validate primary_grouping
  valid_primary_groupings <- oe_primary_groupings$primary_grouping
  if (!primary_grouping %in% valid_primary_groupings) {
    stop(glue::glue("Invalid primary_grouping '{primary_grouping}'. Must be one of: {paste(valid_primary_groupings, collapse = ', ')}"))
  }

  # Validate secondary_grouping if provided
  if (!is.null(secondary_grouping)) {
    valid_secondary_groupings <- oe_secondary_groupings$secondary_grouping
    if (!secondary_grouping %in% valid_secondary_groupings) {
      stop(glue::glue("Invalid secondary_grouping '{secondary_grouping}'. Must be one of: {paste(valid_secondary_groupings, collapse = ', ')}"))
    }
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
        oe_get_network_data(
          network_code      = network_code,
          metrics           = metrics,
          interval          = interval,
          date_start        = chunk$start,
          date_end          = chunk$end,
          network_region    = network_region,
          fueltech          = fueltech,
          fueltech_group    = fueltech_group,
          primary_grouping  = primary_grouping,
          secondary_grouping = secondary_grouping,
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
    oe_endpoints$oe_api_network_data,
    network_code
  )


  # Build query parameters
  query_params <- list(
    interval = interval,
    metrics = metrics,
    primary_grouping = primary_grouping,
    with_clerk = tolower(as.character(with_clerk))
  )

  # Add optional parameters
  if (!is.null(date_start)) {
    query_params$date_start <- format_datetime(date_start)
  }

  if (!is.null(date_end)) {
    query_params$date_end <- format_datetime(date_end)
  }

  if (!is.null(network_region)) {
    query_params$network_region <- network_region
  }

  if (!is.null(fueltech)) {
    query_params$fueltech <- fueltech
  }

  if (!is.null(fueltech_group)) {
    query_params$fueltech_group <- fueltech_group
  }

  if (!is.null(secondary_grouping)) {
    query_params$secondary_grouping <- secondary_grouping
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

  # Convert to data frame, passing grouping names for dynamic column naming
  df <- parse_network_data(
    content$data,
    primary_grouping_name = primary_grouping,
    secondary_grouping_name = secondary_grouping
  )

  return(df)



}
