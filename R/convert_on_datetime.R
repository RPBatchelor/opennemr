#' Convert datetime format from OpenNEM into R friendly datetime format
#'
#' @param dt datetime from OpenNEM API call
#' @param return R friendly datetime format
#'
#' @return datetime format for use within R
#' @export
#'
#' @examples
#' convert_on_datetime("2023-03-01T10:00:00+10:00",
#'                     return = "aware")
#'


convert_on_datetime <- function(dt,
                                return = "aware"){

  assertthat::assert_that(return %in% c("aware", "naive"))

  # Extract the components from OpenNEM datetime format
  # E.g. "2023-03-01T10:00:00Z+10:00"

  date_component <- stringr::str_extract(dt, "\\d{4}\\-\\d{2}\\-\\d{2}")
  time_component <- stringr::str_extract(dt, "\\d{2}\\:\\d{2}\\:\\d{2}")
  timezone_component <- stringr::str_extract(dt, "[+-]\\d{2}\\:\\d{2}")


  if(return == "aware"){

    dt_output <- paste0(date_component,
                        " ",
                        time_component)
    dt_output <- as.POSIXct(dt_output, tz = "Australia/Sydney")

  } else if (return == "naive"){

    dt_output <- paste0(date_component,
                        " ",
                        time_component)

  } else {

    print("must return either naive or aware")
    dt_output <- NULL

  }

  return(dt_output)

}
