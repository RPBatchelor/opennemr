#' Get energy data by station
#'
#' @param network_code String defining the network code to return data for (e.g. "NEM")
#' @param station_code String defining the station to return data fro (e.g. "LOYYANGA")
#' @param interval String defining the interval of data
#' @param period String defining the period of data to request
#'
#' @return dataframe of energy data (MWh) by station
#' @export
#'
#'
#'@examples
#'
#' df <- get_energy_by_station(network_code = "NEM",
#'                             station_code = "LOYYANGA",
#'                             interval = "1d",
#'                             period = "7d")
#'


get_energy_by_station <- function(network_code,
                                  station_code,
                                  interval = "1d",
                                  period = "7d"){


  intervals <- get_interval_list()
  periods <- get_period_list()
  networks <- get_network_list()
  stations <- get_station_list()

  assertthat::assert_that(network_code %in% unique(networks$network_code))
  assertthat::assert_that(station_code %in% unique(stations$station_code))
  assertthat::assert_that(interval %in% unique(intervals$interval_human))
  assertthat::assert_that(period %in% unique(periods$period_human))

  endpoint <- glue::glue("https://api.opennem.org.au/stats/energy/station/{network_code}/{station_code}")

  query_params <- list(
    interval = interval,
    period = period)

  response <- httr::GET(url = endpoint, query = query_params)

  if(response$status_code == 200){

    response_content <- httr::content(response,
                                      as = "text",
                                      encoding = "UTF-8")
    raw_data <- jsonlite::fromJSON(response_content)

    data <- raw_data$data |>
      tidyr::unnest() |>
      tidyr::unnest(data) |>
      dplyr::select(code, network, data_type, units, data) |>
      dplyr::mutate(data = as.numeric(data))

    data_types <- data |>
      dplyr::distinct(data_type)

    print(glue::glue("Dataset contains {length(data_types$data_type)} data types.
           {data_types}"))

    facility_list <- data |>
      dplyr::distinct(code)
    num_facilities <- length(facility_list$code)

    facility_data_full <- tibble::tibble()

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
        dplyr::filter(interval_human == a) |>
        dplyr::pull(intervals_seq)

      facility_ii_data <- data |>
        dplyr::filter(code == facility_ii)

      date_time_ii <- seq(from = as.POSIXct(start_date_time_ii),
                          to = as.POSIXct(end_date_time_ii),
                          by = temp_int_ii) |>
        tibble::as_tibble() |>
        dplyr::rename("period_start" = "value")

      date_time_ii <- repeat_df_rows(date_time_ii, length(data_types$data_type))

      facility_ii_data <- facility_ii_data |>
        dplyr::bind_cols(date_time_ii)

      facility_data_full <- facility_data_full |>
        dplyr::bind_rows(facility_ii_data) |>
        dplyr::mutate(data_interval = interval)

    }

    # Clean final dataset before returning
    facility_data_full <- facility_data_full |>
      dplyr::rename("value" = "data")
    return(facility_data_full)

  } else {

    response_code_message(response$status_code)
    stop()

  }

}






