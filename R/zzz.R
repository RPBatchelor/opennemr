

.onAttach <- function(libname = find.package("opennemr"), pkgname = "opennemr"){
  # Check the status of the OpenNEM API
  api_version <- check_api_version()
  check_api_status()

  packageStartupMessage(
    glue::glue("The current version of OpenNEM API is {api_version}")
    )



}
