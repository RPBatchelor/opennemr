#' Get historical power by station data
#'
#' @param network_code String defining the network code to return data for (e.g. "NEM")
#' @param station_code String defining the station to return data fro (e.g. "LOYYANGA")
#' @param interval String defining the interval of data
#' @param period String defining the period of data to request
#'
#' @return dataframe power by station
#' @export
#'
#' @examples
#' df <- get_power_by_station(network_code = "NEM",
#'                            station_code = "LOYYANGA",
#'                            interval = "1d",
#'                            period = "7d")


get_power_by_station <- function(network_code,
                                 station_code,
                                 interval = "30m",
                                 period = "7d"){

  # assertthat::assert_that(network_code %in% unique(networks$network_code))
  # assertthat::assert_that(station_code %in% unique(station_list$station_code))
  # assertthat::assert_that(interval %in% unique(intervals$interval_human))
  # assertthat::assert_that(period %in% unique(periods$period_human))

  endpoint <- glue::glue("https://api.opennem.org.au/stats/power/station/{network_code}/{station_code}")

  query_params <- list(
    interval_human = interval,
    period_human = period)

  response <- httr::GET(url = endpoint, query = query_params)

  if(response$status_code == 200){

    response_content <- httr::content(response, as = "text")
    raw_data <- jsonlite::fromJSON(response_content)

    data <- raw_data$data |>
      tidyr::unnest() |>
      tidyr::unnest(data) |>
      dplyr::select(code, network, data_type, units, data) |>
      dplyr::mutate(data = as.numeric(data))

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
        dplyr::filter(interval_human == a) |>
        dplyr::pull(intervals_seq)

      facility_ii_data <- data |>
        dplyr::filter(code == facility_ii)

      date_time_ii <- seq(from = as.POSIXct(start_date_time_ii),
                          to = as.POSIXct(end_date_time_ii),
                          by = temp_int_ii) |>
        tibble::as_tibble() |>
        dplyr::rename("period_start" = "value")

      facility_ii_data <- facility_ii_data |>
        dplyr::bind_cols(date_time_ii)

      facility_data_full <- facility_data_full |>
        dplyr::bind_rows(facility_ii_data)

    }



  } else if(response$status_code == 404) {

    response_404()

  } else {

    response_undefined(response$status_code)

  }


  return(facility_data_full)

  rm(a, end_date_time_ii, endpoint, facility_ii, ii, interval, network_code,
     num_facilities, period, response_content, start_date_time_ii, station_code,
     temp_int_ii, data, date_time_ii, facility_data_full, facility_ii_data,
     query_params, raw_data, response)

}






