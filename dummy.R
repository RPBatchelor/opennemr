

# usethis::edit_r_environ()

devtools::load_all()

oe_check_user()


# Check oe_get_network_data()
result <- oe_get_network_data(
  network_code = "NEM",
  metrics = c("energy"),
  interval = "1h",
  date_start = "2024-12-01",
  date_end = "2024-12-02"
)

head(result)




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





