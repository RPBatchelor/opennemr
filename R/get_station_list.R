#' Get list of stations available in OpenNEM
#'
#' @return Dataframe of stations and facilities
#' @export
#'
#' @examples
#' df <- get_station_list()


get_station_list <- function(){

  endpoint <- "https://api.opennem.org.au/station/"
  response <- httr::GET(url = endpoint)

  if(response$status_code == 200){

    # response_200()

    response_content <- httr::content(response,
                                      as = "text",
                                      encoding = "UTF-8")
    stations <- jsonlite::fromJSON(response_content)
    cols_to_keep <- c(1:5, 7:9, 11:12, 14, 17:21, 23:30, 34, 37)
    stations <- tibble::tibble(stations$data) |>
      tidyr::unnest_wider(facilities, names_sep = "_") |>
      tidyr::unnest() |>
      janitor::clean_names() |>
      dplyr::select(all_of(cols_to_keep)) |>
      dplyr::rename("station_id" = "id",
             "station_code" = "code",
             "station_name" = "name",
             "network_code" = "code1",
             "network_label" = "label",
             "timezone_code" = "timezone_database",
             "fueltech_code" = "code2",
             "fueltech_label" = "label1",
             "status_code" = "code3")

  } else {

    response_code_message(response$status_code)

  }

  return(stations)

}
