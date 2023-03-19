#' HTML Response 200 - OK
#'
#' @return Message against defined and undefined html response codes
#' @export
#'
#' @examples
#'

response_200 <- function(){
  return_msg <- "Response 200 - OK"
  message(return_msg)
}


# HTML Response 404 - Not Found
#' Title
#'
#' @return
#' @export
#'
#' @examples
#'

response_404 <- function(){
  return_msg <- "Response 404 - Not Found.
  There was no response from the server. This suggests input parameters
  may have been wrong, or the URL was incorrect.
  Please check all inputs and try again"
  message(return_msg)
}


# HTML Response 400 - Bad Request
#' Title
#'
#' @return
#' @export
#'
#' @examples
#'

response_400 <- function(){
  return_msg <- "Response 400 - Bad request.
  This API call returned bad request.
  Please check all inputs and try again"
  message(return_msg)
}


# HTML Response undefined - return actual error code with generic message
#' Title
#'
#' @param response_code
#'
#' @return
#' @export
#'
#' @examples
#'

response_undefined <- function(response_code){
  return_msg <- glue::glue("Error - response code {response_code}.
  This API call could not be completed.
  Please check all inputs and try again")
  message(return_msg)
}

