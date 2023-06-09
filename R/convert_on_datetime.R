#' Convert datetime format from OpenNEM into R friendly datetime format
#'
#' @param dt datetime from OpenNEM API call
#' @param return R friendly datetime format
#'
#' @return datetime format for use within R
#'
#' @examples
#' \dontrun{
#' convert_on_datetime(dt = "2023-03-01Z 12:00:00T")
#'}

convert_on_datetime <- function(dt,
                                return = "aware"){

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
