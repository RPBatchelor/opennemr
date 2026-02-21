#' Helper function to parse facilities API response data into a data frame
#' @param data List from API response
#' @return Data frame with fully unnested location and units
#' @keywords internal

parse_facilities_data <- function(data) {

  # Check for empty data
  if (length(data) == 0) {
    warning("No data returned from API")
    return(data.frame())
  }

  # Unnest top level only, keeping location and units as list-columns
  df <- purrr::map_df(data, function(facility) {
    desc <- facility$description %||% NA_character_
    desc <- gsub("<[^>]+>", "", desc)
    desc <- trimws(desc)

    tibble::tibble(
      code = facility$code %||% NA_character_,
      name = facility$name %||% NA_character_,
      network_id = facility$network_id %||% NA_character_,
      network_region = facility$network_region %||% NA_character_,
      description = desc,
      location = list(facility$location),
      units = list(facility$units)
    )
  })

  # Unnest location and units
  df <- df |>
    tidyr::unnest_wider(location) |>
    tidyr::unnest_longer(units) |>
    tidyr::unnest_wider(units, names_sep = "_")

  # Convert numeric columns (API returns these as character strings)
  numeric_cols <- c(
    "units_capacity_registered",
    "units_capacity_maximum",
    "units_capacity_storage",
    "units_max_generation"
  )

  df <- df |>
    dplyr::mutate(dplyr::across(dplyr::any_of(numeric_cols), as.numeric))

  # Convert datetime columns (API returns ISO 8601 strings)
  # Handles: "+10:00" offsets, "Z" suffix, and bare datetime strings (no tz)
  datetime_cols <- c(
    "units_data_first_seen",
    "units_data_last_seen",
    "units_commencement_date",
    "units_expected_closure_date",
    "units_expected_operation_date",
    "units_max_generation_interval",
    "units_created_at",
    "units_updated_at"
  )

  parse_iso_datetime <- function(x) {
    if (is.null(x) || length(x) == 0) return(as.POSIXct(character(0)))
    # Normalise: "Z" → "+0000", "+HH:MM" → "+HHMM" for strptime %z
    x_norm <- gsub("Z$", "+0000", x)
    x_norm <- gsub("([+-]\\d{2}):(\\d{2})$", "\\1\\2", x_norm)
    # Parse with timezone offset
    result <- suppressWarnings(
      as.POSIXct(x_norm, format = "%Y-%m-%dT%H:%M:%S%z", tz = "UTC")
    )
    # Fall back to no-timezone parse (e.g. units_max_generation_interval)
    failed <- is.na(result) & !is.na(x)
    if (any(failed)) {
      result[failed] <- suppressWarnings(
        as.POSIXct(x[failed], format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
      )
    }
    result
  }

  df <- df |>
    dplyr::mutate(dplyr::across(dplyr::any_of(datetime_cols), parse_iso_datetime))

  return(df)
}
