#' Get facilities from OpenElectricity API
#'
#' @description
#' Retrieve a list of electricity generation and storage facilities from the
#' OpenElectricity API v4. Results can be filtered by facility code, status,
#' fuel technology, network, and region.
#'
#' @param facility_code Character vector. Filter by one or more facility codes. Default: NULL (all facilities).
#' @param status_id Character vector. Filter by facility status. Valid values: "committed", "operating", "retired". Default: NULL (all statuses).
#' @param fueltech_id Character vector. Filter by fuel technology type. See `oe_fueltechs` for valid values. Default: NULL (all fueltechs).
#' @param network_id Character vector. Filter by network code(s). Valid values: "NEM", "WEM", "AEMO_ROOFTOP", "APVI". Default: NULL (all networks).
#' @param network_region Character. Filter by network region. Valid values: "NSW1", "QLD1", "SA1", "TAS1", "VIC1", "SNOWY1", "WEM". Default: NULL (all regions).
#' @param with_clerk Logical. Include clerk data in response. Default: TRUE.
#' @param api_key Character. OpenElectricity API key. If NULL, uses OPEN_ELECTRICITY_API_KEY environment variable. Default: NULL.
#'
#' @return List containing facility data objects from the API.
#'
#' @examples
#' \dontrun{
#' # Get all operating facilities
#' facilities <- oe_get_facilities(status_id = "operating")
#'
#' # Get all coal facilities in NEM
#' coal_facilities <- oe_get_facilities(
#'   fueltech_id = c("coal_black", "coal_brown"),
#'   network_id = "NEM"
#' )
#'
#' # Get facilities in Victoria
#' vic_facilities <- oe_get_facilities(network_region = "VIC1")
#' }
#'
#' @export
oe_get_facilities <- function(facility_code = NULL,
                              status_id = NULL,
                              fueltech_id = NULL,
                              network_id = NULL,
                              network_region = NULL,
                              with_clerk = TRUE,
                              api_key = NULL
                              ){

  # Get API key
  if (is.null(api_key)) {
    api_key <- oe_get_api()
  }


  # Validate parameter values against reference data

  # Validate status_id if provided
  if (!is.null(status_id)) {
    valid_statuses <- c("committed", "operating", "retired")
    invalid_statuses <- status_id[!status_id %in% valid_statuses]
    if (length(invalid_statuses) > 0) {
      stop(sprintf(
        "Invalid status_id(s): %s. Valid statuses are: %s",
        paste(invalid_statuses, collapse = ", "),
        paste(valid_statuses, collapse = ", ")
      ))
    }
  }

  # Validate fueltech_id if provided
  if (!is.null(fueltech_id)) {
    valid_fueltechs <- oe_fueltechs$fueltech
    invalid_fueltechs <- fueltech_id[!fueltech_id %in% valid_fueltechs]
    if (length(invalid_fueltechs) > 0) {
      stop(sprintf(
        "Invalid fueltech_id(s): %s. Valid fueltechs are: %s",
        paste(invalid_fueltechs, collapse = ", "),
        paste(valid_fueltechs, collapse = ", ")
      ))
    }
  }

  # Validate network_id if provided
  if (!is.null(network_id)) {
    valid_networks <- oe_network_list$network_name
    invalid_networks <- network_id[!network_id %in% valid_networks]
    if (length(invalid_networks) > 0) {
      stop(sprintf(
        "Invalid network_id(s): %s. Valid networks are: %s",
        paste(invalid_networks, collapse = ", "),
        paste(valid_networks, collapse = ", ")
      ))
    }
  }

  # Validate network_region if provided
  if (!is.null(network_region)) {
    valid_regions <- oe_network_regions$region
    if (!network_region %in% valid_regions) {
      stop(sprintf(
        "Invalid network_region '%s'. Valid regions are: %s",
        network_region,
        paste(valid_regions, collapse = ", ")
      ))
    }
  }


  # Build the endpoint URL
  endpoint <- paste0(
    oe_endpoints$oe_api_base_url,
    oe_endpoints$oe_api_facilities
  )


  # Build query parameters
  query_params <- list(
    with_clerk = tolower(as.character(with_clerk))
  )

  # Add optional array parameters
  # For multiple values with the same parameter name, we need to add them individually
  if (!is.null(facility_code)) {
    for (code in facility_code) {
      query_params <- c(query_params, list(facility_code = code))
    }
  }

  if (!is.null(status_id)) {
    for (status in status_id) {
      query_params <- c(query_params, list(status_id = status))
    }
  }

  if (!is.null(fueltech_id)) {
    for (fueltech in fueltech_id) {
      query_params <- c(query_params, list(fueltech_id = fueltech))
    }
  }

  if (!is.null(network_id)) {
    for (network in network_id) {
      query_params <- c(query_params, list(network_id = network))
    }
  }

  # Add single-value optional parameters
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

  print(glue::glue("Fetched {content$total_records} records."))

  # Check if request was successful
  if (!isTRUE(content$success)) {
    stop(paste("API error:", content$error))
  }

  # Parse and return the data as a tidy data frame
  df <- parse_facilities_data(content$data)

  return(df)


}
