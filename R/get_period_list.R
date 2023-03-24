#' Get list of periods available in OpenNEM API
#'
#' @return Dataframe of periods
#' @export
#'
#' @examples
#' get_period_list()

get_period_list <- function(){

  # Call the endpoint as defined in the API documentation
  # https://api.opennem.org.au/docs
  endpoint <- "https://api.opennem.org.au/periods"
  response <- httr::GET(url = endpoint)

  if(response$status_code == 200){

    # response_200()

    response_content <- httr::content(response,
                                      as = "text",
                                      encoding = "UTF-8")
    periods <- jsonlite::fromJSON(response_content) |>
      tidyr::unnest(cols=c())


  } else {

    response_code_message(response$status_code)

  }

  return(periods)

}
