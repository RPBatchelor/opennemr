


oe_check_user <-  function(){

  api_key <- oe_get_api()

  endpoint <- paste0(oe_endpoints$oe_api_base_url, oe_endpoints$oe_api_user_me)

  req <- httr2::request(endpoint) |>
    httr2::req_headers(
      Authorization = paste("Bearer", api_key),
      # Optional: content negotiation; the API typically returns JSON
      Accept = "application/json"
    ) |>
    httr2::req_timeout(30) # seconds

  # Perform request and check for errors
  resp <- httr2::req_perform(req)

  resp |> httr2::resp_check_status()

  # Parse JSON response into an R list
  content <- resp |>
    httr2::resp_body_json(simplifyVector = TRUE)


  print(glue::glue("Valid user: {content$data$full_name} \n"))
  print(glue::glue("User plan: {content$data$plan} \n"))
  print(glue::glue("API calls remaining: {content$data$meta$remaining}  \n"))


}
