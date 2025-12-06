#' Helper function to parse API response data into a data frame
#' @param data List from API response
#' @return Data frame
#' @keywords internal


parse_network_data <- function(data) {
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

    return(df)
  })

  # Combine all result sets
  df <- do.call(rbind, all_results)
  rownames(df) <- NULL

  return(df)
}
