#' Get list of fueltechs available in OpenNEM API
#'
#' @return Dataframe of fueltechs
#' @export
#'
#' @examples
#' get_fueltech_list()
#'

get_fueltech_list <- function(){

  # Call the endpoint as defined in the API documentation
  # https://api.opennem.org.au/docs
  endpoint <- "https://api.opennem.org.au/fueltechs"
  response <- httr::GET(url = endpoint)

  if(response$status_code == 200){

    response_content <- httr::content(response,
                                      as = "text",
                                      encoding = "UTF-8")
    fueltechs <- jsonlite::fromJSON(response_content) |>
      tidyr::unnest(cols = c())

    # Tidy the returned dataframe
    fueltechs <- fueltechs |>
      dplyr::rename("fueltech_code" = "code",
                    "fueltech_label" = "label",
                    "renewable_flag" = "renewable")

  } else {

    response_code_message(response$status_code)

  }

  return(fueltechs)

}
