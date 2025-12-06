

oe_get_api <- function(){

  api_key <- Sys.getenv("OPEN_ELECTRICITY_API_KEY")

  if (nzchar(api_key) == FALSE) stop("API key not found.\n
                                     Set OPEN_ELECTRICITY_API_KEY in your environment. \n
                                     Check the documentation on how to get an API key")

  return(api_key)

}
