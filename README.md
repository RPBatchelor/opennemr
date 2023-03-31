
<!-- README.md is generated from README.Rmd. Please edit that file -->

# opennemr

<!-- badges: start -->
<!-- badges: end -->

The goal of opennemr is to provide simple access to the OpenNEM API via
R. Each of the endpoints documented at <https://api.opennem.org.au/docs>
have been implemented in opennemr.

## Installation

You can install the development version of opennemr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("RPBatchelor/opennemr")
```

## Example

This is a basic example which shows you how to solve a common problem:

Query the OpenNEM API to get a list of fueltechs available.

``` r
library(opennemr)
## basic example code
get_network_list()
#> # A tibble: 11 × 6
#>    network_code country network_label region_code timezone         interval_size
#>    <chr>        <chr>   <chr>         <chr>       <chr>                    <int>
#>  1 AEMO_ROOFTOP au      AEMO Rooftop  NSW1        Australia/Sydney            30
#>  2 AEMO_ROOFTOP au      AEMO Rooftop  QLD1        Australia/Sydney            30
#>  3 AEMO_ROOFTOP au      AEMO Rooftop  VIC1        Australia/Sydney            30
#>  4 AEMO_ROOFTOP au      AEMO Rooftop  TAS1        Australia/Sydney            30
#>  5 AEMO_ROOFTOP au      AEMO Rooftop  SA1         Australia/Sydney            30
#>  6 NEM          au      NEM           NSW1        Australia/Sydney             5
#>  7 NEM          au      NEM           QLD1        Australia/Sydney             5
#>  8 NEM          au      NEM           VIC1        Australia/Sydney             5
#>  9 NEM          au      NEM           TAS1        Australia/Sydney             5
#> 10 NEM          au      NEM           SA1         Australia/Sydney             5
#> 11 WEM          au      WEM           WEM         Australia/Perth             30
```

Download power and price data from OpenNEM API for a given month and
region

``` r
library(ggplot2)
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
#> ✔ tibble  3.1.8     ✔ dplyr   1.1.0
#> ✔ tidyr   1.3.0     ✔ stringr 1.5.0
#> ✔ readr   2.1.4     ✔ forcats 1.0.0
#> ✔ purrr   1.0.1     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()

df <- get_power_by_fueltech_region(
  network_code = "NEM",
  network_region_code = "VIC1",
  month = "2023-03-01"
)

p <- df |> 
  filter(period_start >= "2023-03-01" & 
           period_start < "2023-03-02",
         type == "power") |> 
  ggplot() +
  geom_area(aes(x = period_start, y = data, fill = fueltech))
p
```

<img src="man/figures/README-power data example-1.png" width="100%" />
