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

  return(df)
}
