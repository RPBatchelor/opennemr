#' Get energy data by station
#'
#' @param network_code
#' @param station_code
#' @param interval
#' @param period
#'
#' @return dataframe of energy data (MWh) by station
#' @export
#'
#' @examples
#' df <- get_energy_by_station(network_code = "NEM",
#'                             station_code = "LOYYANGA",
#'                             interval = "1d",
#'                             period = "7d")


get_energy_by_station <- function(network_code,
                                  station_code,
                                  interval = "1d",
                                  period = "7d"){

  # assertthat::assert_that(network_code %in% unique(networks$network_code))
  # assertthat::assert_that(station_code %in% unique(station_list$station_code))
  # assertthat::assert_that(interval %in% unique(intervals$interval_human))
  # assertthat::assert_that(period %in% unique(periods$period_human))

  endpoint <- glue("https://api.opennem.org.au/stats/energy/station/{network_code}/{station_code}")

  query_params <- list(
    interval = interval,
    period = period)

  response <- GET(url = endpoint, query = query_params)

  if(response$status_code == 200){

    response_content <- content(response, as = "text")
    raw_data <- fromJSON(response_content)

    data <- raw_data$data |>
      unnest() |>
      unnest(data) |>
      select(code, network, data_type, units, data) |>
      mutate(data = as.numeric(data))

    data_types <- data |>
      distinct(data_type)

    print(glue("Dataset contains {length(data_types$data_type)} data types.
           {data_types}"))

    facility_list <- data |>
      distinct(code)
    num_facilities <- length(facility_list$code)

    facility_data_full <- tibble()

    # Loop through each facility within the station
    for(ii in 1:num_facilities){

      facility_ii <- facility_list$code[[ii]]

      position_vector <- seq(1:num_facilities) *
        length(raw_data$data$code)/num_facilities - 2

      start_date_time_ii <- raw_data$data$history$start[[position_vector[[ii]]]] |>
        convert_on_datetime(return = "aware")
      end_date_time_ii <- raw_data$data$history$last[[position_vector[[ii]]]] |>
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

      date_time_ii <- repeat_df_rows(date_time_ii, length(data_types$data_type))

      facility_ii_data <- facility_ii_data |>
        bind_cols(date_time_ii)

      facility_data_full <- facility_data_full |>
        bind_rows(facility_ii_data) |>
        mutate(data_interval = interval)

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

  rm(endpoint, query_params, response, response_content, raw_data, data,
     data_types, facility_list, facility_data_full, ii, facility_ii,
     position_vector, start_date_time_ii, end_date_time_ii, a, temp_int_ii,
     facility_ii_data, date_time_ii)

}






