#' Helper function to parse API response data into a data frame
#'
#' @description
#' Parses time series data from the OpenElectricity API, converting datetime strings
#' to POSIXct and extracting grouping information from series names.
#'
#' @param data List from API response
#' @param primary_grouping_name Character. Name of the primary grouping parameter (e.g., "network", "network_region").
#'   If provided, creates a column with this name. Default: NULL.
#' @param secondary_grouping_name Character. Name of the secondary grouping parameter (e.g., "fueltech", "fueltech_group").
#'   If provided, creates a column with this name. Default: NULL.
#'
#' @return Data frame with columns:
#' \describe{
#'   \item{datetime}{POSIXct timestamp with network timezone}
#'   \item{value}{Numeric value for the metric}
#'   \item{[grouping_name]}{Dynamically named column(s) based on grouping parameters used}
#'   \item{network_code}{Network identifier}
#'   \item{metric}{Metric type}
#'   \item{unit}{Unit of measurement}
#'   \item{interval}{Time interval}
#' }
#'
#' @details
#' The function extracts grouping information from the series_name field using regex:
#' - Format: "metric_primary|secondary" → Creates columns with actual grouping names
#' - Format: "metric_primary" → Creates one column with primary grouping name
#' - Format: "metric" → No grouping columns created
#'
#' @keywords internal


parse_network_data <- function(data,
                                primary_grouping_name = NULL,
                                secondary_grouping_name = NULL) {
  if (length(data) == 0) {
    warning("No data returned from API")
    return(data.frame())
  }


  # data is a list of result sets (one per metric/grouping combo)
  all_results <- lapply(data, function(result_set) {
    # Extract metadata
    metadata <- list(
      network_code = result_set$network_code,
      metric = result_set$metric,
      unit = result_set$unit,
      interval = result_set$interval
    )

    if (is.null(result_set$results) || length(result_set$results) == 0) {
      return(data.frame())
    }

    # Each result in results has name, date_start, date_end, columns, data
    series_dfs <- lapply(result_set$results, function(series) {
      if (is.null(series$data) || length(series$data) == 0) {
        return(data.frame())
      }

      # Extract timestamp/value pairs
      df <- data.frame(
        datetime = sapply(series$data, `[[`, 1),
        value = sapply(series$data, `[[`, 2),
        stringsAsFactors = FALSE
      )

      # Add series name
      df$series_name <- series$name

      return(df)
    })

    df <- do.call(rbind, series_dfs)

    # Add metadata columns
    df$network_code <- metadata$network_code
    df$metric <- metadata$metric
    df$unit <- metadata$unit
    df$interval <- metadata$interval

    # Convert datetime strings to POSIXct with proper timezone
    df$datetime <- convert_oe_datetime(df$datetime, network_code = metadata$network_code)

    return(df)
  })

  # Combine all result sets
  df <- do.call(rbind, all_results)
  rownames(df) <- NULL

  # Extract grouping information from series_name if present
  # Format: "metric_primary|secondary" or "metric_primary" or just "metric"
  if (nrow(df) > 0 && "series_name" %in% names(df)) {

    # Track if we extracted any groupings
    extracted_grouping <- FALSE

    # Extract primary grouping value if grouping name provided
    if (!is.null(primary_grouping_name)) {
      df <- df |>
        dplyr::mutate(
          !!primary_grouping_name := dplyr::case_when(
            # Has both _ and |: extract between them
            grepl("_.*\\|", series_name) ~ stringr::str_extract(series_name, "(?<=_)[^|]+(?=\\|)"),
            # Has _ but no |: extract after _
            grepl("_", series_name) ~ stringr::str_extract(series_name, "(?<=_).+$"),
            # No _: no primary grouping
            TRUE ~ NA_character_
          )
        )
      extracted_grouping <- TRUE
    }

    # Extract secondary grouping value if grouping name provided
    if (!is.null(secondary_grouping_name)) {
      df <- df |>
        dplyr::mutate(
          !!secondary_grouping_name := dplyr::if_else(
            grepl("\\|", series_name),
            stringr::str_extract(series_name, "(?<=\\|).+$"),
            NA_character_
          )
        )
      extracted_grouping <- TRUE
    }

    # Only remove series_name if we extracted grouping information
    # Otherwise keep it for downstream processing (e.g., facility parser)
    if (extracted_grouping) {
      df <- df |>
        dplyr::select(-series_name)

      # Reorder columns for readability - put grouping columns after value
      grouping_cols <- c(primary_grouping_name, secondary_grouping_name)
      grouping_cols <- grouping_cols[!is.null(grouping_cols)]

      df <- df |>
        dplyr::select(
          datetime,
          value,
          dplyr::any_of(grouping_cols),
          network_code,
          metric,
          unit,
          interval
        )
    }
  }

  return(df)
}
