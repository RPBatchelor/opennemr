#' Helper function to parse facilities API response data into a data frame
#' @param data List from API response
#' @return Data frame
#' @keywords internal


parse_facilities_data <- function(data) {
  if (length(data) == 0) {
    warning("No data returned from API")
    return(data.frame())
  }

  # Process each facility
  facilities_list <- lapply(data, function(facility) {
    # Flatten the facility object recursively
    flatten_facility(facility)
  })

  # Combine all facilities into a single data frame
  df <- dplyr::bind_rows(facilities_list)

  # Clean column names
  df <- janitor::clean_names(df)

  return(df)
}


#' Helper function to recursively flatten a nested list
#' @param x List to flatten
#' @param parent Character prefix for nested names
#' @return Named list with flattened structure
#' @keywords internal
flatten_facility <- function(x, parent = "") {
  result <- list()

  for (name in names(x)) {
    # Create the full name with parent prefix
    full_name <- if (parent == "") name else paste(parent, name, sep = "_")

    element <- x[[name]]

    # Handle NULL values
    if (is.null(element)) {
      result[[full_name]] <- NA
    }
    # Handle lists (nested objects)
    else if (is.list(element) && !is.data.frame(element)) {
      # Check if it's an unnamed list (array)
      if (is.null(names(element)) || all(names(element) == "")) {
        # For arrays, convert to comma-separated string or handle specially
        if (length(element) == 0) {
          result[[full_name]] <- NA
        } else if (all(sapply(element, function(e) is.atomic(e) && length(e) == 1))) {
          # Simple array of atomic values
          result[[full_name]] <- paste(unlist(element), collapse = ", ")
        } else {
          # Complex nested array - flatten each element
          for (i in seq_along(element)) {
            sub_result <- flatten_facility(element[[i]], paste0(full_name, "_", i))
            result <- c(result, sub_result)
          }
        }
      } else {
        # Named list (object) - recurse
        sub_result <- flatten_facility(element, full_name)
        result <- c(result, sub_result)
      }
    }
    # Handle atomic values
    else {
      result[[full_name]] <- element
    }
  }

  return(result)
}
