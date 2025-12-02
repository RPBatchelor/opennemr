





# install.packages("httr2")   # if not already installed
library(httr2)
library(jsonlite)

# Recommended: keep your API key out of code (e.g., set in .Renviron as OPEN_ELECTRICITY_API_KEY=...)
api_key <- ""

if (nzchar(api_key) == FALSE) stop("API key not found. Set OPEN_ELECTRICITY_API_KEY in your environment.")

req <- request("https://api.openelectricity.org.au/v4/me") |>
  req_headers(
    Authorization = paste("Bearer", api_key),
    # Optional: content negotiation; the API typically returns JSON
    Accept = "application/json"
  ) |>
  req_timeout(30) # seconds

# Perform the request and check for errors
resp <- req_perform(req)

# Throw a descriptive error for non-2xx status codes
resp |> resp_check_status()

# Parse JSON response into an R list/data frame
content <- resp |> resp_body_json(simplifyVector = TRUE)
str(content)   # inspect the structure
print(content)









