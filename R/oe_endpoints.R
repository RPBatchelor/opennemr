




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
