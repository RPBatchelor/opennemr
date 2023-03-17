# Get fueltech list
#
# This functions makes a call to the OpenNEM API and returns a list of
# fueltechs in OpenNEM backend database.
# The function returns the list as a dataframe object
#


get_fueltech_list <- function(){

  # Call the endpoint as defined in the API documentation
  # https://api.opennem.org.au/docs
  endpoint <- "https://api.opennem.org.au/fueltechs"
  response <- httr::GET(url = endpoint)

  if(response$status_code == 200){

    response_200()

    response_content <- content(response, as = "text")
    fueltechs <- jsonlite::fromJSON(response_content) |>
      tidyr::unnest(cols = c())

    # Tidy the returned dataframe
    fueltechs <- fueltechs |>
      dplyr::rename("fueltech_code" = "code",
                    "fueltech_label" = "label",
                    "renewable_flag" = "renewable")

  } else if(response$status_code == 404) {

    response_404()

  } else {

    response_undefined(response$status_code)

  }

  return(fueltechs)

}
