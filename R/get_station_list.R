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
    stations_raw <- jsonlite::fromJSON(response_content)
    cols_to_keep <- c("station_id",
                      "station_code",
                      "station_name",
                      "location_id",
                      "facilities_id",
                      "network_code",
                      "fueltech_code",
                      "renewable",
                      "status_code",
                      "facilities_code",
                      "facilities_dispatch_type",
                      "facilities_active",
                      "facilities_capacity_registered",
                      "facilities_unit_number",
                      "facilities_network_region",
                      "facilities_unit_number",
                      "facilities_unit_capacity",
                      "facilities_emissions_factor_co2",
                      "facilities_registered",
                      "description")


    stations <- tibble::tibble(stations_raw$data) |>
      tidyr::unnest_wider(facilities, names_sep = "_") |>
      tidyr::unnest(cols = c(facilities_id,
                             facilities_network,
                             facilities_fueltech,
                             facilities_status,
                             facilities_station_id,
                             facilities_code,
                             facilities_dispatch_type,
                             facilities_active,
                             facilities_capacity_registered,
                             facilities_network_region,
                             facilities_unit_number,
                             facilities_unit_capacity,
                             facilities_emissions_factor_co2,
                             facilities_approved),
                    names_repair = "universal") |>
      janitor::clean_names() |>
      dplyr::rename("station_id" = "id",
                    "station_code" = "code_2",
                    "station_name" = "name",
                    "network_code" = "code_6",
                    "fueltech_code" = "code_7",
                    "status_code" = "code_10") |>
      dplyr::select(dplyr::all_of(cols_to_keep))


  } else {

    response_code_message(response$status_code)

  }

  return(stations)

}


















