# 6-Dec-25
# Ryan batchelor


# Creates the v4 API data structure for reference

library(tidyverse)

# List of networks
oe_network_list <- tibble::tribble(
  ~network_name,    ~network_type,  ~network_timezone,  ~data_from,
  "NEM",            "primary",      "UTC+10",           as.Date("1998-12-06"),
  "WEM",            "primary",      "UTC+8",            as.Date("2006-09-19"),
  "AEMO_ROOFTOP",   "secondary",    "UTC+10",           as.Date("2018-03-01"),
  "APVI",           "secondary",    "UTC+10",           as.Date("2015-03-19")
)


# List of regions per network
oe_network_regions <- tibble::tribble(
  ~region,  ~region_name,                   ~network_name,
  "NSW1",   "New South Wales (inc. ACT)",   "NEM",
  "QLD1",   "Queensland",                   "NEM",
  "SA1",    "South Australia",              "NEM",
  "TAS1",   "Tasmania",                     "NEM",
  "VIC1",   "Victoria",                     "NEM",
  "SNOWY1", "Snowy Mountains region",       "NEM",
  "WEM",    "Western Australia",            "WEM"
)


# List of interconnectors between networks
oe_network_interconnectors <- tibble::tribble(
  ~interconnector, ~interconnector_description,       ~network_name,
  "NSW1-QLD1",     "Queensland to NSW",               "NEM",
  "VIC1-NSW1",     "Victoria to NSW",                 "NEM",
  "VIC1-SA1",      "Victoria to SA",                  "NEM",
  "VIC1-TAS1",     "Victoria to Tasmania (Basslink)", "NEM"
)


# Simplified fueltech groups
oe_fueltech_groups <- tibble::tribble(
  ~fueltech_group,        ~group_lable,            ~renewable, ~colour,
  "coal",                 "Coal",                  FALSE,      "#101010",
  "gas",                  "Gas",                   FALSE,      "#e87809",
  "wind",                 "Wind",                  TRUE,       "#2c7629",
  "solar",                "Solar",                 TRUE,       "#fed500",
  "battery_charging",     "Battery (Charging)",    FALSE,      "#577cff",
  "battery_discharging",  "Battery (Discharging)", FALSE,      "#3245c9",
  "hydro",                "Hydro",                 TRUE,       "#5ea0c0",
  "distillate",           "Distillate",            FALSE,      "#e15c34",
  "bioenergy",            "Bioenergy",             TRUE,       "#1d7a7a",
  "pumps",                "Pumps",                 FALSE,      "#88afd0"
)


# List of all fuetechs
oe_fueltechs <- tibble::tribble(
  ~fueltech,             ~fueltech_lable,         ~fueltech_group,      ~renewable, ~colour,
  "battery_charging",    "Battery (Charging)",    "battery_charging",    FALSE,     "#577cff",
  "battery_discharging", "Battery (Discharging)", "battery_discharging", FALSE,     "#3245c9",
  "bioenergy_biogas",    "Biogas",                "bioenergy",           TRUE,      "#26a0a0",
  "bioenergy_biomass",   "Biomass",               "bioenergy",           TRUE,      "#1d7a7a",
  "coal_black",          "Coal (Black)",          "coal",                FALSE,     "#101010",
  "coal_brown",          "Coal (Brown)",          "coal",                FALSE,     "#7c4926",
  "distillate",          "Distillate",            "distillate",          FALSE,     "#e15c34",
  "gas_ccgt",            "Gas (CCGT)",            "gas",                 FALSE,     "#fdb462",
  "gas_ocgt",            "Gas (OCGT)",            "gas",                 FALSE,     "#ffcd96",
  "gas_recip",           "Gas (Reciprocating",    "gas",                 FALSE,     "#f9dcbc",
  "gas_steam",           "Gas (Steam)",           "gas",                 FALSE,     "#f48e1b",
  "gas_wcmg",            "Gas (Coal Mine Waste)", "gas",                 FALSE,     "#b46813",
  "hydro",               "Hydro",                 "hydro",               TRUE,      "#5ea0c0",
  "pumps",               "Pumps",                 "pumps",               FALSE,     "#88afd0",
  "solar_rooftop",       "Solar (Rooftop)",       "solar",               TRUE,      "#fff58d",
  "solar_thermal",       "Solar (Thermal)",       "solar",               TRUE,      "#ffe600",
  "solar_utility",       "Solar (Utility)",       "solar",               TRUE,      "#fed500",
  "wind",                "Wind",                  "wind",                TRUE,      "#2c7629",
  "wind_offshore",       "Offshore Wind",         "wind",                TRUE,      "#53ad69",
  "aggregator_vpp",      "Aggregator (VPP)",      "",                    TRUE,      "#cbcbcb",
  "aggregator_dr",       "Aggregator (DR)",       "",                    TRUE,      "#7f7f7f",
  "nuclear",             "Nuclear",               "",                    FALSE,     "#ca1dee",
  "imports",             "Network Import",        "",                    FALSE,     "#521986",
  "exports",             "Netowrk Export",        "",                    FALSE,     "#927bad",
  "interconnector",      "Interconnector",        "",                    FALSE,     "#672c9c",
  "battery",             "Battery",               "",                    FALSE,     "#3f65eb"
)


oe_intervals <- tibble::tribble(
  ~interval,  ~interval_desc,
  "5m",       "5 minutes",
  "1h",       "1 hour",
  "1d",       "1 day",
  "7d",       "7 days",
  "1M",       "1 month",
  "3M",       "3 months",
  "season",   "Season",
  "1y",       "1 Year",
  "fy",       "Financial year"
)

oe_metrics <- tibble::tribble(
  ~metric, ~metric_attribute, ~metric_unit,
  "power", "Instantaneous power output/consumption (MW)", "MW",
  "energy", "Energy generated/consumed over time (MWh)", "MWh",
  "price", "Price per unit of energy ($/MWh)", "$/MWh",
  "market_value", "Total market value ($)", "$",
  "demand", "Demand for power (MW)", "MW",
  "demand_energy", "Demand for energy (MWh)", "MWh",
  "emissions", "CO2 equivalent emissions (tonnes)", "tCO2-e",
  "renewable_proportion", "Percentage of renewable energy (%)", "%"
)


# Export

usethis::use_data(oe_network_list, overwrite = TRUE)
usethis::use_data(oe_network_regions, overwrite = TRUE)
usethis::use_data(oe_network_interconnectors, overwrite = TRUE)
usethis::use_data(oe_fueltech_groups, overwrite = TRUE)
usethis::use_data(oe_fueltechs, overwrite = TRUE)
usethis::use_data(oe_intervals, overwrite = TRUE)
usethis::use_data(oe_metrics, overwrite = TRUE)



