

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

  # Validate network_code
  valid_networks <- oe_network_list$network_name
  if (!network_code %in% valid_networks) {
    stop(sprintf(
      "Invalid network_code '%s'. Must be one of: %s",
      network_code,
      paste(valid_networks, collapse = ", ")
    ))
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
    stop(sprintf(
      "Invalid metric '%s'. Valid metrics are: %s",
      metrics,
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

  # Validate fueltech if provided
  if (!is.null(fueltech)) {
    valid_fueltechs <- oe_fueltechs$fueltech
    if (!fueltech %in% valid_fueltechs) {
      stop(sprintf(
        "Invalid fueltech '%s'. Must be one of: %s",
        fueltech,
        paste(valid_fueltechs, collapse = ", ")
      ))
    }
  }

  # Validate fueltech_group if provided
  if (!is.null(fueltech_group)) {
    valid_fueltech_groups <- oe_fueltech_groups$fueltech_group
    if (!fueltech_group %in% valid_fueltech_groups) {
      stop(sprintf(
        "Invalid fueltech_group '%s'. Must be one of: %s",
        fueltech_group,
        paste(valid_fueltech_groups, collapse = ", ")
      ))
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

  # Convert to data frame
  df <- parse_network_data(content$data)

  return(df)



}
