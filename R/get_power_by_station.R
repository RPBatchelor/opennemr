#' Get historical power by station data
#'
#' @param network_code
#' @param station_code
#' @param interval
#' @param period


get_power_by_station <- function(network_code,
                                 station_code,
                                 interval = "30m",
                                 period = "7d"){

  assertthat::assert_that(network_code %in% unique(networks$network_code))
  assertthat::assert_that(station_code %in% unique(station_list$station_code))
  assertthat::assert_that(interval %in% unique(intervals$interval_human))
  assertthat::assert_that(period %in% unique(periods$period_human))

  endpoint <- glue("https://api.opennem.org.au/stats/power/station/{network_code}/{station_code}")

  query_params <- list(
    interval_human = interval,
    period_human = period)

  response <- GET(url = endpoint, query = query_params)

  if(response$status_code == 200){

    response_content <- content(response, as = "text")
    raw_data <- fromJSON(response_content)

    data <- raw_data$data |>
      unnest() |>
      unnest(data) |>
      select(code, network, data_type, units, data) |>
      mutate(data = as.numeric(data))

    num_facilities <- length(raw_data$data$code)

    facility_data_full <- tibble()

    for(ii in 1:num_facilities){

      facility_ii <- raw_data$data$code[[ii]]
      start_date_time_ii <- raw_data$data$history$start[[ii]] |>
        convert_on_datetime(return = "aware")
      end_date_time_ii <- raw_data$data$history$last[[ii]] |>
        convert_on_datetime(return = "aware")

      a <- as.character(interval)

      temp_int_ii <- intervals |>
        filter(interval_human == a) |>
        pull(intervals_seq)

      facility_ii_data <- data |>
        filter(code == facility_ii)

      date_time_ii <- seq(from = as.POSIXct(start_date_time_ii),
                          to = as.POSIXct(end_date_time_ii),
                          by = temp_int_ii) |>
        as_tibble() |>
        rename("period_start" = "value")

      facility_ii_data <- facility_ii_data |>
        bind_cols(date_time_ii)

      facility_data_full <- facility_data_full |>
        bind_rows(facility_ii_data)

    }



  } else if(response$status_code == 404) {

    print(glue("Error 404. There was no response from the server.
    This suggests input parameters may have been wrong, or the URL was incorrect.
    Please try again."))
  } else {

    print(glue("Error {response$status_code}.
    Unknown error. Please check all inputs and try again"))

  }


  return(facility_data_full)

  rm(a, end_date_time_ii, endpoint, facility_ii, ii, interval, network_code,
     num_facilities, period, response_content, start_date_time_ii, station_code,
     temp_int_ii, data, date_time_ii, facility_data_full, facility_ii_data,
     query_params, raw_data, response)

}






