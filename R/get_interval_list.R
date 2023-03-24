#' Get list of intervals available in OpenNEM API
#'
#' @return Dataframe of intervals
#' @export
#'
#' @examples
#' get_interval_list()

get_interval_list <- function(){

  # Call the endpoint as defined in the API documentation
  # https://api.opennem.org.au/docs
  endpoint <- "https://api.opennem.org.au/intervals"
  response <- httr::GET(url = endpoint)

  if(response$status_code == 200){

    # response_200()

    response_content <- httr::content(response,
                                      as = "text",
                                      encoding = "UTF-8")
    intervals <- jsonlite::fromJSON(response_content) |>
      tidyr::unnest(cols = c())

    intervals_seq <- c("5 min",
                       "10 min",
                       "15 min",
                       "30 min",
                       "hour",
                       "day",
                       "week",
                       "week",
                       "month",
                       "quarter",
                       "year")

    intervals <- intervals |>
      dplyr::bind_cols("intervals_seq" = intervals_seq)


  } else {

    response_code_message(response$status_code)

  }

  return(intervals)

}
