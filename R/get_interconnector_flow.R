#' Interconnector flow power data
#'
#' @param network_code String defining the network to request data for
#' @param month String defining the month of data to request (format "YYYY-MM-DD")
#'
#' @return Dataframe of power flow data for interconnectors
#' @export
#'
#' @examples
#' df <- get_interconnector_flow_by_network(network_code = "NEM",
#'                                          month = "2023-03-01")

get_interconnector_flow_by_network <- function(network_code,
                                               month){

  networks <- get_network_list()
  assertthat::assert_that(network_code %in% unique(networks$network_code))

  intervals <- get_interval_list()

  endpoint <- glue::glue("https://api.opennem.org.au/stats/flow/network/{network_code}")

  query_params <- list(
    month = month)

  response <- httr::GET(url = endpoint, query = query_params)


  interconnector_data_full <- tibble::tibble()


  if(response$status_code == 200){


    response_content <- httr::content(response,
                                      as = "text",
                                      encoding = "UTF-8")
    raw_data <- jsonlite::fromJSON(response_content)

    data <- raw_data$data |>
      tidyr::unnest() |>
      tidyr::unnest(data) |>
      dplyr::select(-c(id, network, start, last)) |>
      dplyr::mutate(data = as.numeric(data))

    interconnectors_list <- data |>
      dplyr::distinct(code)
    num_interconnectors <- length(interconnectors_list$code)

    print(glue::glue("Dataset contains data for {num_interconnectors} interconnectors.
           {interconnectors_list}"))


    interconnector_data_full <- tibble::tibble()

    for(ii in 1:num_interconnectors){

      interconnector_ii <- interconnectors_list$code[[ii]]

      start_date_time_ii <- raw_data$data$history$start[[ii]]|>
        convert_on_datetime(return = "aware")
      end_date_time_ii <- raw_data$data$history$last[[ii]]|>
        convert_on_datetime(return = "aware")
      interval_ii <- raw_data$data$history$interval[[ii]]

      temp_int_ii <- intervals |>
        dplyr::filter(interval_human == interval_ii) |>
        dplyr::pull(intervals_seq)

      interconnector_ii_data <- data |>
        dplyr::filter(code == interconnector_ii)

      date_time_ii <- seq(from = as.POSIXct(start_date_time_ii),
                          to = as.POSIXct(end_date_time_ii),
                          by = temp_int_ii) |>
        tibble::as_tibble() |>
        dplyr::rename("period_start" = "value")

      assertthat::are_equal(length(interconnector_ii_data$data),
                            length(date_time_ii$period_start))


      interconnector_ii_data <- interconnector_ii_data |>
        dplyr::bind_cols(date_time_ii)

      interconnector_data_full <- interconnector_data_full |>
        dplyr::bind_rows(interconnector_ii_data)
    }


  } else {

    response_code_message(response$status_code)
  }

  interconnector_data_full <- interconnector_data_full |>
    dplyr::rename("value" = "data")

  return(interconnector_data_full)



}

