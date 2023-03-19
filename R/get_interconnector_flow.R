

#' Title
#'
#' @param network_code
#' @param month
#'
#' @return
#' @export
#'
#' @examples
get_interconnector_flow_by_network <- function(network_code,
                                               month){


  assertthat::assert_that(network_code %in% unique(networks$network_code))

  endpoint <- glue("https://api.opennem.org.au/stats/flow/network/{network_code}")

  query_params <- list(
    month = month)

  response <- GET(url = endpoint, query = query_params)

  response$status_code

  assertthat::are_equal(response$status_code,200)

  # insert if status code == 200

  response_content <- content(response, as = "text")
  raw_data <- fromJSON(response_content)

  data <- raw_data$data |>
    unnest() |>
    unnest(data) |>
    select(-c(id, network, start, last)) |>
    mutate(data = as.numeric(data))

  interconnectors_list <- data |>
    distinct(code)
  num_interconnectors <- length(interconnectors_list$code)

  print(glue("Dataset contains data for {num_interconnectors} interconnectors.
           {interconnectors_list}"))


  interconnector_data_full <- tibble()


  if(response$status_code == 200){


    response_content <- content(response, as = "text")
    raw_data <- fromJSON(response_content)

    data <- raw_data$data |>
      unnest() |>
      unnest(data) |>
      select(-c(id, network, start, last)) |>
      mutate(data = as.numeric(data))

    interconnectors_list <- data |>
      distinct(code)
    num_interconnectors <- length(interconnectors_list$code)

    print(glue("Dataset contains data for {num_interconnectors} interconnectors.
           {interconnectors_list}"))


    interconnector_data_full <- tibble()

    for(ii in 1:num_interconnectors){

      # ii <- 1

      interconnector_ii <- interconnectors_list$code[[ii]]

      start_date_time_ii <- raw_data$data$history$start[[ii]]|>
        convert_on_datetime(return = "aware")
      end_date_time_ii <- raw_data$data$history$last[[ii]]|>
        convert_on_datetime(return = "aware")
      interval_ii <- raw_data$data$history$interval[[ii]]

      temp_int_ii <- intervals |>
        filter(interval_human == interval_ii) |>
        pull(intervals_seq)

      interconnector_ii_data <- data |>
        filter(code == interconnector_ii)

      date_time_ii <- seq(from = as.POSIXct(start_date_time_ii),
                          to = as.POSIXct(end_date_time_ii),
                          by = temp_int_ii) |>
        as_tibble() |>
        rename("period_start" = "value")

      assertthat::are_equal(length(interconnector_ii_data$data),
                            length(date_time_ii$period_start))


      interconnector_ii_data <- interconnector_ii_data |>
        bind_cols(date_time_ii)

      interconnector_data_full <- interconnector_data_full |>
        bind_rows(interconnector_ii_data)
    }


  } else if(response$status_code == 404) {

    print(glue("Error 404. There was no response from the server.
    This suggests input parameters may have been wrong, or the URL was incorrect.
    Please try again."))
  } else {

    print(glue("Error {response$status_code}.
    Unknown error. Please check all inputs and try again"))
  }

  return(interconnector_data_full)

  rm(network_code, month, endpoint, query_params, response, response_content,
     raw_data, data, interconnectors_list, num_interconnectors,
     interconnector_data_full, interconnector_ii, start_date_time_ii,
     end_date_time_ii, interval_ii, temp_int_ii, date_time_ii,
     interconnector_ii_data)


}

