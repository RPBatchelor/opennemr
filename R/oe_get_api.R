#' Get OpenElectricity API key from environment
#'
#' @description
#' Internal helper function that retrieves the OpenElectricity API key from
#' the system environment variable. This function is called by all API functions
#' to ensure authentication is properly configured.
#'
#' @details
#' The API key must be stored in the environment variable \code{OPEN_ELECTRICITY_API_KEY}.
#' To set this up:
#' \enumerate{
#'   \item Run \code{usethis::edit_r_environ()} to open your .Renviron file
#'   \item Add the line: \code{OPEN_ELECTRICITY_API_KEY=your_key_here}
#'   \item Restart R for the changes to take effect
#' }
#'
#' You can obtain an API key from the OpenElectricity developer platform at
#' \url{https://platform.openelectricity.org.au}
#'
#' @return Character string containing the API key
#'
#' @section Error:
#' Stops with an error message if the \code{OPEN_ELECTRICITY_API_KEY} environment
#' variable is not set or is empty.
#'
#' @seealso \code{\link{oe_check_user}} to verify your API key is working
#'
#' @keywords internal
oe_get_api <- function(){

  api_key <- Sys.getenv("OPEN_ELECTRICITY_API_KEY")

  if (nzchar(api_key) == FALSE) stop("API key not found.\n
                                     Set OPEN_ELECTRICITY_API_KEY in your environment. \n
                                     Check the documentation on how to get an API key")

  return(api_key)

}
