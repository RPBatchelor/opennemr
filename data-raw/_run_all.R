# 6-Dec-25
# Ryan batchelor

# Run all files in data-raw

library(tidyverse)
library(glue)

files <- list.files("data-raw", pattern = ".R$")
files <- files[!stringr::str_detect(files, "_run_all")]

purrr::walk(glue::glue("data-raw/{files}"),
            source)

#save internal only datasets
usethis::use_data(oe_network_list,
                  oe_network_regions,
                  oe_network_interconnectors,
                  oe_fueltech_groups,
                  oe_fueltechs,
                  oe_intervals,
                  oe_metrics,
                  internal = TRUE, overwrite = TRUE)

