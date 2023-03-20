#' Get power data by fueltech and network region
#'
#' @param network_code String defining the network code to return data for (e.g. "NEM")
#' @param network_region_code String defining the network region (e.g. "VIC1")
#' @param month String defining the month of data to request (format "YYYY-MM-DD")
#'
#' @return Dataframe of power/price data by fueltech
#' @export
#'
#' @examples
#'df <- get_power_by_fueltech_region(network_code = "NEM",
#'                                   network_region_code = "VIC1",
#'                                  month = "2023-02-01")


get_power_by_fueltech_region <- function(network_code,
                                         network_region_code,
                                         month){

#
#   assertthat::assert_that(network_code %in% unique(networks$network_code))
#   assertthat::assert_that(network_region_code %in% unique(networks$region_code))

  endpoint <- glue::glue("https://api.opennem.org.au/stats/power/network/fueltech/{network_code}/{network_region_code}")

  query_params <- list(
    month = month)

  response <- httr::GET(url = endpoint, query = query_params)

  response$status_code

  if(response$status_code == 200){

    response_content <- hrrt::content(response, as = "text")
    raw_data <- jsonlite::fromJSON(response_content)

    fueltech_list <- raw_data$data$code
    type_list <- raw_data$data$type
    unit_list <- raw_data$data$units

    data <- raw_data |>
      dplyr::bind_rows()

    data_historical <- raw_data$data$history

    data_fueltech_full <- tibble::tibble()

    for(ii in 1:length(fueltech_list)){

      fueltech_ii <- fueltech_list[[ii]]
      type_ii <- type_list[[ii]]

      start_date_time_ii <- data_historical[[1]][[ii]] |>
        convert_on_datetime(return = "aware")
      end_date_time_ii <- data_historical[[2]][[ii]]|>
        convert_on_datetime(return = "aware")
      interval_ii <- data_historical[[3]][[ii]]

      raw_data_ii <- data_historical[ii, ] |>
        tibble::as_tibble() |>
        tidyr::unnest(data) |>
        dplyr::mutate(fueltech = fueltech_ii)

      temp_int_ii <- intervals |>
        dplyr::filter(interval_human == interval_ii) |>
        dplyr::pull(intervals_seq)

      date_time_ii <- seq(from = start_date_time_ii,
                          to = end_date_time_ii,
                          by = temp_int_ii) |>
        tibble::as_tibble() |>
        dplyr::rename("period_start" = "value")

      raw_data_ii <- raw_data_ii |>
        bind_cols(date_time_ii) |>
        select(-c(start, last)) |>
        mutate(type = type_ii,
               network_region = network_region_code)

      data_fueltech_full <- data_fueltech_full |>
        bind_rows(raw_data_ii)

    }
  } else if(response$status_code == 404) {

    response_404()

  } else {

    response_undefined(response$status_code)
  }

  return(data_fueltech_full)

  rm(network_code, network_region_code, endpoint, query_params, response,
     response_content, raw_data, fueltech_list, type_list, unit_list,
     data, data_historical, data_fueltech_full, ii, fueltech_ii, type_ii,
     start_date_time_ii, end_date_time_ii, interval_ii, temp_int_ii,
     date_time_ii, raw_data_ii)


}











