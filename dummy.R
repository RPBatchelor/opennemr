

# usethis::edit_r_environ()

devtools::load_all()

oe_check_user()


# Check oe_get_network_data()
result <- oe_get_network_data(
  network_code = "NEM",
  metrics = "energy",
  interval = "1h",
  date_start = "2024-12-01",
  date_end = "2024-12-02"
)

head(result)




