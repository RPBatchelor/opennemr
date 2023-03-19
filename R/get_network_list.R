#' Get list of networks available in OpenNEM API
#'
#' @return Dataframe of networks and network regions
#' @export
#'
#' @examples
#' get_network_list()
#'


get_network_list <- function(){

  # Call the endpoint as defined in the API documentation
  # https://api.opennem.org.au/docs
  endpoint <- "https://api.opennem.org.au/networks"
  response <- httr::GET(url = endpoint)

  if(response$status_code == 200){

    response_200()

    response_content <- httr::content(response, as = "text")
    networks <- jsonlite::fromJSON(response_content) |>
      tidyr::unnest(cols = c(regions), names_sep = "-")

    networks <- networks |>
      dplyr::rename("network_code" = "code",
             "network_label" = "label",
             "region_code" = "regions-code")


  } else if(response$status_code == 404) {

    response_404()

  } else {

    response_undefined(response$status_code)

  }

  return(networks)

}
