#' Check API version
#'
#' Queries the main OpenNEM page to get version number
#'
#' @noRd
#'

check_api_version <- function(suppress_messages = TRUE){

  # Create a new chromote session to extract API information from the
  # OpenNEM API documentation site
  b <- chromote::ChromoteSession$new()
  # b$Browser$getVersion()

  url <- "https://api.opennem.org.au/docs"
  b$Page$navigate(url)

  # Extract the API version
  page_data <- b$Runtime$evaluate('document.querySelector("h1").innerText')
  api_text <- page_data$result$value
  api_version <- stringr::str_extract(api_text, pattern = "\\((.+?)\\)", group = 1)

  b$close()

  message(glue::glue("API version: {api_version}"))

  return(api_version)

}




#' Check status of the OpenNEM API
#'
#'
#' @noRd
#'

check_api_status <- function(suppress_messages = TRUE){

  # Create a new chromote session to extract API information from the
  # OpenNEM status page
  b <- chromote::ChromoteSession$new()
  # b$Browser$getVersion()

  url <- "https://status.opennem.org.au/"
  b$Page$navigate(url)

  # Extract the overall status and status of the OpenNEM API
  page_data <- b$Runtime$evaluate('document.querySelector(".status").innerText')
  status_text <- page_data$result$value

  overall_status <- stringr::str_extract(status_text, pattern = "(.+?)\\\n", group = 1)
  api_status <- stringr::str_extract(status_text, pattern = "API\\n(.+?)\\n", group = 1)

  message(writeLines(c(glue::glue("Overall Status: {overall_status}"),
                       glue::glue("API status: {api_status}"))))


  b$close()


}




