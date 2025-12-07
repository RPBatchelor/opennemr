#' OpenElectricity API v4 Endpoints
#'
#' @description
#' Internal list containing base URL and endpoint paths for the OpenElectricity API v4.
#' This object is stored in R/sysdata.rda and used internally by all API functions.
#'
#' @format A named list with 6 elements:
#' \describe{
#'   \item{oe_api_base_url}{Base URL for the OpenElectricity API: "https://api.openelectricity.org.au"}
#'   \item{oe_api_network_data}{Endpoint path for network time series data: "/v4/data/network/"}
#'   \item{oe_api_facility_data}{Endpoint path for facility time series data: "/v4/data/facilities/"}
#'   \item{oe_api_market_data}{Endpoint path for market data (price, demand): "/v4/market/network/"}
#'   \item{oe_api_facilities}{Endpoint path for facilities list: "/v4/facilities/"}
#'   \item{oe_api_user_me}{Endpoint path for user verification: "/v4/me"}
#' }
#'
#' @details
#' This is an internal data object that centralizes all API endpoint definitions.
#' It is accessed by functions like \code{oe_get_facilities()}, \code{oe_get_network_data()},
#' and \code{oe_check_user()} to construct full API URLs.
#'
#' @keywords internal
oe_endpoints <- list(
  oe_api_base_url = "https://api.openelectricity.org.au", # Base url
  oe_api_network_data = "/v4/data/network/",               # Time series data for network
  oe_api_facility_data = "/v4/data/facilities/",           # Time series data for a facility
  oe_api_market_data = "/v4/market/network/",              # Market data (price, demand)
  oe_api_facilities = "/v4/facilities/",                   # List of facilities
  oe_api_user_me = "/v4/me"                                # Check user
)

# Save internal
usethis::use_data(oe_endpoints,
                  internal = TRUE,
                  overwrite = TRUE)
