

library(tidyverse)
library(httr)
library(plotly)


devtools::load_all()

oe_check_user()


# Check oe_get_network_data()


# Get hourly energy data for NEM
nem_energy <- oe_get_network_data(
  network_code = "NEM",
  metrics = "energy",
  interval = "1h",
  date_start = "2024-12-01",
  date_end = "2024-12-31"
)



# Get hourly energy data for NEM
nem_energy_long_duration <- oe_get_network_data(
  network_code = "NEM",
  metrics = "energy",
  interval = "1h",
  date_start = "2025-01-01",
  date_end = "2025-02-28"
)


p <- nem_energy_long_duration |>
  ggplot(aes(x = datetime, y = value)) +
  geom_line()

p


y# Get power data for Victoria only
vic_power <- oe_get_network_data(
  network_code = "NEM",
  metrics = "power",
  interval = "1h",
  date_start = "2025-01-01",
  date_end = "2025-01-31",
  network_region = "VIC1"
)

str(vic_power)


p <- vic_power |>
  ggplot(aes(x = datetime, y = value)) +
  geom_line()

p



# Get emissions data for coal generation
coal_emissions <- oe_get_network_data(
  network_code = "NEM",
  metrics = "emissions",
  interval = "1d",
  fueltech_group = "coal"
)



nem_energy <- oe_get_network_data(
  network_code = "NEM",
  metrics = "energy",
  interval = "1h",
  date_start = "2024-12-01",
  date_end = "2024-12-31",
  primary_grouping = "network_region",
  secondary_grouping = "fueltech_group"
)


p <- nem_energy |>
  ggplot(aes(x = datetime, y = value, fill = fueltech_group)) +
  geom_area() +
  facet_wrap(~network_region)

p



# Test 1: Get all facilities (no filters)
all_facilities <- oe_get_facilities()

# Test 2: Get operating facilities only
operating <- oe_get_facilities(status_id = "operating")

# Test 3: Get coal facilities in NEM
coal_nem <- oe_get_facilities(
  fueltech_id = c("coal_black", "coal_brown"),
  network_id = "NEM"
)

# Test 4: Get facilities in Victoria
vic_facilities <- oe_get_facilities(network_region = "VIC1")

# Test 5: Combine multiple filters
filtered <- oe_get_facilities(
  status_id = c("operating", "committed"),
  network_id = "NEM",
  fueltech_id = "solar_utility"
)








# Get power data for Loy Yang A
lya_power <- oe_get_facility_data(
  network_code = "NEM",
  metrics = "power",
  facility_code = "LOYYANGA",
  interval = "1h",
  date_start = "2024-12-01",
  date_end = "2024-12-31"
)


p <- lya_power |>
  ggplot(aes(x = datetime, y = value, fill = unit_code)) +
  geom_area()

p





with_clerk = TRUE




# Get multiple metrics (power + emissions)
lya_multi <- oe_get_facility_data(
  network_code = "NEM",
  metrics = c("power", "emissions"),
  facility_code = "LOYYANGA",
  interval = "1d"
)

str(lya_multi)



# Compare multiple facilities
coal_plants <- oe_get_facility_data(
  network_code = "NEM",
  metrics = "power",
  facility_code = c("LOYYANGA", "HAVPS"),
  interval = "1h"
)

# All facilities in network (warning: may be large!)
all_nem_power <- oe_get_facility_data(
  network_code = "NEM",
  metrics = "power",
  interval = "1d"
)





# Get NEM electricity prices
nem_prices <- oe_get_network_market_data(
  network_code = "NEM",
  metrics = "price",
  interval = "1h",
  date_start = "2024-12-01",
  date_end = "2024-12-07"
)

str(nem_prices)


# Get multiple market metrics for Victoria
vic_market <- oe_get_network_market_data(
  network_code = "NEM",
  metrics = c("price", "demand", "market_value"),
  interval = "1d",
  network_region = "VIC1"

)

# Get multiple market metrics for Victoria
vic_market <- oe_get_network_market_data(
  network_code = "NEM",
  metrics = c("price", "demand"),
  interval = "1d",
  network_region = "VIC1"
)

# The above throws an error. Likely API bug
oe_get_network_market_data("NEM",
                           metrics = "market_value",
                           interval = "1d")


# Compare demand across all NEM regions
regional_demand <- oe_get_network_market_data(
  network_code = "NEM",
  metrics = "demand",
  interval = "1h",
  primary_grouping = "network_region"
)

# Price and demand time series
price_demand <- oe_get_network_market_data(
  network_code = "NEM",
  metrics = c("price", "demand"),
  interval = "5m"
)



#
# TESTING AREA


api_key <- Sys.getenv("OPEN_ELECTRICITY_API_KEY")

response <- httr::GET(
  url = "https://api.openelectricity.org.au/v4/market/network/NEM",
  query = list(
    metrics = "price",
    interval = "1d",
    date_start = "2025-01-01T00:00:00",
    date_end = "2025-01-03T00:00:00"
  ),
  httr::add_headers(
    "Authorization" = paste("Bearer", api_key),
    "Content-Type" = "application/json"
  )
)

content <- httr::content(response, as = "parsed", encoding = "UTF-8")

# Show structure up to 5 levels deep
str(content$data, max.level = 5)



# Show first 3 data points from the first result series
content$data[[1]]$results[[1]]$data[1:3]



oe_network_list
subset(oe_network_regions, network_name == "NEM")


oe_fueltechs

oe_metrics


operating <- oe_get_facilities(
  status_id = "operating",
  network_id = "NEM"
)


glimpse(operating)


p <- operating |>
  mutate(
    state = gsub("[0-9]", "", network_region),
  ) |>
  summarise(
    capacity = sum(units_capacity_registered, na.rm = TRUE),
    .by = c(state, units_fueltech_id)
  ) |>
  ggplot(aes(x = state, y = capacity, fill = units_fueltech_id)) +
  geom_col() +
  labs(
    x = "State",
    y = "Maximum Capacity (MW)",
    fill = "Fuel Tech"
  ) +
  theme_minimal()

ggplotly(p)



