



response_200 <- function(){

  # Returns a string for a 200 response code
  return_msg <- "Response 200 - OK"

  return(return_msg)

}


response_404 <- function(){

  # Return string for a 404 error code
  # 404 means "not found"

  return_msg <- "Response 404 - Not Found.
  There was no response from the server. This suggests input parameters
  may have been wrong, or the URL was incorrect.
  Please check all inputs and try again"

  return(return_msg)

}


response_400 <- function(){

  # Return string for a 400 error code
  # 400 means "bad request"

  return_msg <- "Response 400 - Bad request.
  This API call returned bad request.
  Please check all inputs and try again"

  return(return_msg)

}


response_undefined <- function(response_code){

  # Return string for undefined response

  return_msg <- glue("Response {response_code}.
  This API call could not be completed.
  Please check all inputs and try again")

  return(return_msg)

}

