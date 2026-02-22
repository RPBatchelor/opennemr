# Suppress R CMD check notes about undefined global variables
# These are all exported datasets or non-standard evaluation variables
utils::globalVariables(c(
  "oe_fueltech_groups",
  "oe_fueltechs",
  "oe_intervals",
  "oe_metrics",
  "oe_network_list",
  "oe_network_regions",
  "location"
))

.onAttach <- function(libname = find.package("opennemr"), pkgname = "opennemr"){

  # # Check the status of the OpenNEM API
  # api_version <- check_api_version()
  # check_api_status()
  #
  # packageStartupMessage(
  #   glue::glue("The current version of OpenNEM API is {api_version}")
  #   )



}
