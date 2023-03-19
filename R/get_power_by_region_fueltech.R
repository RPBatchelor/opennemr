#' Title
#'
#' @param network_code
#' @param network_region_code
#' @param month
#'
#' @return
#' @export
#'
#' @examples
get_power_by_fueltech_region <- function(network_code,
                                         network_region_code,
                                         month){


  assertthat::assert_that(network_code %in% unique(networks$network_code))
  assertthat::assert_that(network_region_code %in% unique(networks$region_code))

  endpoint <- glue("https://api.opennem.org.au/stats/power/network/fueltech/{network_code}/{network_region_code}")

  query_params <- list(
    month = month)

  response <- GET(url = endpoint, query = query_params)

  response$status_code

  if(response$status_code == 200){

    response_content <- content(response, as = "text")
    raw_data <- fromJSON(response_content)

    fueltech_list <- raw_data$data$code
    type_list <- raw_data$data$type
    unit_list <- raw_data$data$units

    data <- raw_data |>
      bind_rows()

    data_historical <- raw_data$data$history

    data_fueltech_full <- tibble()

    for(ii in 1:length(fueltech_list)){

      fueltech_ii <- fueltech_list[[ii]]
      type_ii <- type_list[[ii]]

      start_date_time_ii <- data_historical[[1]][[ii]] |>
        convert_on_datetime(return = "aware")
      end_date_time_ii <- data_historical[[2]][[ii]]|>
        convert_on_datetime(return = "aware")
      interval_ii <- data_historical[[3]][[ii]]

      raw_data_ii <- data_historical[ii, ] |>
        as_tibble() |>
        unnest(data) |>
        mutate(fueltech = fueltech_ii)

      temp_int_ii <- intervals |>
        filter(interval_human == interval_ii) |>
        pull(intervals_seq)

      date_time_ii <- seq(from = start_date_time_ii,
                          to = end_date_time_ii,
                          by = temp_int_ii) |>
        as_tibble() |>
        rename("period_start" = "value")

      raw_data_ii <- raw_data_ii |>
        bind_cols(date_time_ii) |>
        select(-c(start, last)) |>
        mutate(type = type_ii,
               network_region = network_region_code)

      data_fueltech_full <- data_fueltech_full |>
        bind_rows(raw_data_ii)

    }
  } else if(response$status_code == 404) {

    print(glue("Error 404. There was no response from the server.
    This suggests input parameters may have been wrong, or the URL was incorrect.
    Please try again."))
  } else {

    print(glue("Error {response$status_code}.
    Unknown error. Please check all inputs and try again"))
  }

  return(data_fueltech_full)

  rm(network_code, network_region_code, endpoint, query_params, response,
     response_content, raw_data, fueltech_list, type_list, unit_list,
     data, data_historical, data_fueltech_full, ii, fueltech_ii, type_ii,
     start_date_time_ii, end_date_time_ii, interval_ii, temp_int_ii,
     date_time_ii, raw_data_ii)


}











