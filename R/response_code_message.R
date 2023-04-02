#' HTML response code handler
#'
#' @param code numeric response code from GET request
#'
#' @return HTML response code message for relevant code
#'
#'
#' @examples
#' \dontrun{
#' response_code_message(200)
#' }
#'


response_code_message <- function(code){

  if(is.null(code)){
    print('You must pass a numeric input to function')
  } else{
    assertthat::is.number(code)
    if (code == 200){
      return_msg <- "Response 200 - OK"
    }
    else if (code == 400){
      return_msg <- "Response 400 - Bad request.
This API call returned bad request.
Please check all inputs and try again"
    }
    else if (code == 404){
      return_msg <- "Response 404 - Not Found.
There was no response from the server. This suggests input parameters
may have been wrong, or the URL was incorrect.
Please check all inputs and try again"
    }
    else if(code == 504){
      return_msg <- "Response 504 - Gateway timeout.
The server did not get a response in time to complete the request.
This is normally not something you can fix, and requires a fix
by the web server you are trying to access.
Double check the request, or try again at a later time"
    } else {
      return_msg <- glue::glue("Error - response code {code}.
This API call could not be completed.
Please check all inputs and try again")
    }
  }
  message(return_msg)
}



