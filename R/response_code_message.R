#' HTML response code handler
#'
#' @return Return defined message for each html response code
#'
#'

response_code_message <- function(code){

  if(is.null(code)){
    print('You must pass a numeric input to function')
  } else{

    assertthat::is.number(code)

    if (code == 200){
      return_msg <- "Response 200 - OK"
      message(return_msg)
    }
    else if (code == 400){
      return_msg <- "Response 400 - Bad request.
                      This API call returned bad request.
                      Please check all inputs and try again"
      message(return_msg)
    }
    else if (code == 404){
      return_msg <- "Response 404 - Not Found.
                    There was no response from the server. This suggests input parameters
                    may have been wrong, or the URL was incorrect.
                    Please check all inputs and try again"
      message(return_msg)
    } else {
      return_msg <- glue::glue("Error - response code {_code}.
                                This API call could not be completed.
                                Please check all inputs and try again")
      message(return_msg)
    }
  }

}



