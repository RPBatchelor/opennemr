#' OpenElectricity Network List
#'
#' @description
#' Reference dataset containing information about electricity networks available
#' in the OpenElectricity API v4.
#'
#' @format A tibble with 4 rows and 4 columns:
#' \describe{
#'   \item{network_name}{Network identifier code (NEM, WEM, AEMO_ROOFTOP, APVI)}
#'   \item{network_type}{Type of network - "primary" for main grids, "secondary" for supplementary data sources}
#'   \item{network_timezone}{Default timezone for the network (e.g., "UTC+10", "UTC+8")}
#'   \item{data_from}{Date when data collection started for this network}
#' }
#'
#' @details
#' The available networks are:
#' - **NEM**: National Electricity Market (eastern and southern Australia)
#' - **WEM**: Wholesale Electricity Market (Western Australia)
#' - **AEMO_ROOFTOP**: AEMO rooftop solar data
#' - **APVI**: Australian PV Institute solar data
#'
#' @examples
#' # View all available networks
#' oe_network_list
#'
#' # Get primary networks only
#' subset(oe_network_list, network_type == "primary")
#'
#' @source OpenElectricity API v4
"oe_network_list"


#' OpenElectricity Network Regions
#'
#' @description
#' Reference dataset containing region codes and names for each electricity network.
#'
#' @format A tibble with 7 rows and 3 columns:
#' \describe{
#'   \item{region}{Region code (NSW1, QLD1, SA1, TAS1, VIC1, SNOWY1, WEM)}
#'   \item{region_name}{Full descriptive name of the region}
#'   \item{network_name}{Parent network identifier (NEM or WEM)}
#' }
#'
#' @details
#' NEM regions include:
#' - NSW1: New South Wales (including ACT)
#' - QLD1: Queensland
#' - SA1: South Australia
#' - TAS1: Tasmania
#' - VIC1: Victoria
#' - SNOWY1: Snowy Mountains region
#'
#' WEM has a single region also called WEM (Western Australia).
#'
#' @examples
#' # View all regions
#' oe_network_regions
#'
#' # Get NEM regions only
#' subset(oe_network_regions, network_name == "NEM")
#'
#' @source OpenElectricity API v4
"oe_network_regions"


#' OpenElectricity Network Interconnectors
#'
#' @description
#' Reference dataset containing information about grid interconnections between regions.
#'
#' @format A tibble with 4 rows and 3 columns:
#' \describe{
#'   \item{interconnector}{Interconnector code showing connected regions (e.g., "NSW1-QLD1")}
#'   \item{interconnector_description}{Descriptive name of the interconnector}
#'   \item{network_name}{Parent network (currently only NEM has interconnectors)}
#' }
#'
#' @details
#' Interconnectors allow electricity to flow between regional grids:
#' - NSW1-QLD1: Queensland to New South Wales
#' - VIC1-NSW1: Victoria to New South Wales
#' - VIC1-SA1: Victoria to South Australia
#' - VIC1-TAS1: Victoria to Tasmania (Basslink submarine cable)
#'
#' @examples
#' # View all interconnectors
#' oe_network_interconnectors
#'
#' # Find interconnectors involving Victoria
#' subset(oe_network_interconnectors, grepl("VIC1", interconnector))
#'
#' @source OpenElectricity API v4
"oe_network_interconnectors"


#' OpenElectricity Fuel Technology Groups
#'
#' @description
#' Reference dataset containing grouped fuel technology categories with metadata.
#'
#' @format A tibble with 10 rows and 4 columns:
#' \describe{
#'   \item{fueltech_group}{Group identifier (e.g., "coal", "solar", "wind")}
#'   \item{group_lable}{Display label for the group}
#'   \item{renewable}{Logical indicating if the group is renewable energy}
#'   \item{colour}{Hex color code for visualization}
#' }
#'
#' @details
#' Fuel technology groups provide a simplified categorization:
#' - **Fossil fuels**: coal, gas, distillate
#' - **Renewables**: wind, solar, hydro, bioenergy
#' - **Storage**: battery_charging, battery_discharging, pumps
#'
#' @examples
#' # View all fuel tech groups
#' oe_fueltech_groups
#'
#' # Get renewable energy groups
#' subset(oe_fueltech_groups, renewable == TRUE)
#'
#' @source OpenElectricity API v4
"oe_fueltech_groups"


#' OpenElectricity Fuel Technologies
#'
#' @description
#' Reference dataset containing detailed fuel technology types with metadata.
#'
#' @format A tibble with 23 rows and 5 columns:
#' \describe{
#'   \item{fueltech}{Technology identifier code (e.g., "coal_black", "solar_utility")}
#'   \item{fueltech_lable}{Display label for the technology}
#'   \item{fueltech_group}{Parent group identifier}
#'   \item{renewable}{Logical indicating if the technology is renewable}
#'   \item{colour}{Hex color code for visualization}
#' }
#'
#' @details
#' Fuel technologies include specific generation types:
#' - **Coal**: coal_black, coal_brown
#' - **Gas**: gas_ccgt, gas_ocgt, gas_recip, gas_steam, gas_wcmg
#' - **Solar**: solar_utility, solar_rooftop, solar_thermal
#' - **Wind**: wind, wind_offshore
#' - **Storage**: battery_charging, battery_discharging, pumps
#' - **Hydro**: hydro
#' - **Bioenergy**: bioenergy_biogas, bioenergy_biomass
#' - **Other**: distillate, nuclear, imports, exports, interconnector
#'
#' @examples
#' # View all fuel technologies
#' oe_fueltechs
#'
#' # Get solar technologies
#' subset(oe_fueltechs, fueltech_group == "solar")
#'
#' # Get all renewable technologies
#' subset(oe_fueltechs, renewable == TRUE)
#'
#' @source OpenElectricity API v4
"oe_fueltechs"


#' OpenElectricity Time Intervals
#'
#' @description
#' Reference dataset containing valid time interval codes for API queries.
#'
#' @format A tibble with 9 rows and 2 columns:
#' \describe{
#'   \item{interval}{Interval code (e.g., "5m", "1h", "1d")}
#'   \item{interval_desc}{Human-readable description}
#' }
#'
#' @details
#' Available intervals range from high-resolution to aggregated:
#' - **Intraday**: 5m (5 minutes), 1h (1 hour)
#' - **Daily and longer**: 1d (1 day), 7d (7 days)
#' - **Monthly**: 1M (1 month), 3M (3 months)
#' - **Annual**: season, 1y (1 year), fy (financial year)
#'
#' Higher resolution intervals (5m, 1h) provide more detailed data but cover
#' shorter maximum time ranges due to API limits.
#'
#' @examples
#' # View all intervals
#' oe_intervals
#'
#' @source OpenElectricity API v4
"oe_intervals"


#' OpenElectricity API Data Limits
#'
#' @description
#' Reference dataset containing the maximum date range allowed per interval when
#' querying the OpenElectricity API. Requests exceeding these limits return a 400
#' error from the API; the package automatically chunks requests that exceed them.
#'
#' @format A tibble with 9 rows and 3 columns:
#' \describe{
#'   \item{interval}{Interval code (e.g., "5m", "1h", "1d")}
#'   \item{max_days}{Maximum number of days allowed per API request for this interval}
#'   \item{max_days_desc}{Human-readable description of the limit (e.g., "8 days")}
#' }
#'
#' @details
#' Limits by interval:
#' - **5m**: 8 days
#' - **1h**: 32 days
#' - **1d / 7d**: 1 year (366 days)
#' - **1M / 3M / season**: 2–5 years
#' - **1y / fy**: ~10 years (3,700 days)
#'
#' @examples
#' # View all data limits
#' oe_data_limits
#'
#' # Find the limit for 5-minute data
#' subset(oe_data_limits, interval == "5m")
#'
#' @source \url{https://docs.openelectricity.org.au/api-reference/data-limits}
"oe_data_limits"


#' OpenElectricity Primary Groupings
#'
#' @description
#' Reference dataset containing valid primary grouping options for network data
#' API queries.
#'
#' @format A tibble with 2 rows and 2 columns:
#' \describe{
#'   \item{primary_grouping}{Grouping identifier code}
#'   \item{grouping_desc}{Description of the grouping}
#' }
#'
#' @source \url{https://docs.openelectricity.org.au/api-reference/data/get-network-data}
"oe_primary_groupings"


#' OpenElectricity Secondary Groupings
#'
#' @description
#' Reference dataset containing valid secondary grouping options for network data
#' API queries. Secondary groupings add a second dimension on top of the primary
#' grouping.
#'
#' @format A tibble with 4 rows and 2 columns:
#' \describe{
#'   \item{secondary_grouping}{Grouping identifier code}
#'   \item{grouping_desc}{Description of the grouping}
#' }
#'
#' @source \url{https://docs.openelectricity.org.au/api-reference/data/get-network-data}
"oe_secondary_groupings"


#' OpenElectricity Metrics
#'
#' @description
#' Reference dataset containing available metrics that can be queried from the API.
#'
#' @format A tibble with 7 rows and 4 columns:
#' \describe{
#'   \item{metric}{Metric identifier code}
#'   \item{metric_attribute}{Description of what the metric measures}
#'   \item{metric_unit}{Unit of measurement}
#'   \item{api_working}{Logical. TRUE if the metric is supported by \code{oe_get_network_data()}.
#'     Metrics marked FALSE return a 400 error from the network data endpoint as of API v4.4.12.}
#' }
#'
#' @details
#' Available metrics and their support in \code{oe_get_network_data()}:
#' - **power** (TRUE): Instantaneous power output/consumption (MW)
#' - **energy** (TRUE): Energy generated/consumed over time (MWh)
#' - **emissions** (TRUE): CO2 equivalent emissions (tonnes)
#' - **price** (FALSE): Use \code{oe_get_network_market_data()} instead
#' - **demand** (FALSE): Use \code{oe_get_network_market_data()} instead
#' - **demand_energy** (FALSE): Use \code{oe_get_network_market_data()} instead
#' - **renewable_proportion** (FALSE): Not currently supported by any endpoint
#'
#' Note: `market_value` is listed in the API docs but returns a 400 error from all
#' endpoints and has been excluded from this table.
#'
#' Note: \code{oe_get_network_data()} only supports querying one metric at a time
#' due to API v4 limitations.
#'
#' @examples
#' # View all metrics
#' oe_metrics
#'
#' # See which metrics work with oe_get_network_data()
#' subset(oe_metrics, api_working)
#'
#' @source OpenElectricity API v4
"oe_metrics"
