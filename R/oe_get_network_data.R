

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


  # Build the required endpoint URL
  endpoint <- paste0(
    oe_endpoints$oe_api_base_url,
    oe_endpoints$oe_api_network_data,
    network_code
  )


  # Build query parameters
  query_params <- list(
    interval = interval,
    primary_grouping = primary_grouping,
    with_clerk = tolower(as.character(with_clerk))
  )

  # Add each metric as a separate parameter
  for (metric in metrics) {
    query_params <- c(query_params, list(metrics = metric))
  }


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
