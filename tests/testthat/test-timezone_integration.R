library(testthat)
library(opennemr)

# Helper: skip the test if no API key is configured
skip_if_no_api_key <- function() {
  key <- Sys.getenv("OPEN_ELECTRICITY_API_KEY")
  if (nchar(trimws(key)) == 0) {
    skip("OPEN_ELECTRICITY_API_KEY not set — skipping live API timezone tests")
  }
}

# Use a summer date range (Australian summer = Nov-Mar).
# This is the critical period: Australia/Sydney shifts to UTC+11 (AEDT) in summer,
# but NEM market time must remain at UTC+10. Any DST bleed would show up here.
DATE_START <- "2025-01-06"
DATE_END   <- "2025-01-08"


# --- NEM ---------------------------------------------------------------

test_that("NEM datetimes are in fixed UTC+10 (Etc/GMT-10), not DST-adjusted Sydney time", {
  skip_if_no_api_key()

  df <- oe_get_network_data(
    network_code = "NEM",
    metrics      = "energy",
    interval     = "1d",
    date_start   = DATE_START,
    date_end     = DATE_END
  )

  expect_s3_class(df$datetime, "POSIXct")

  # Timezone label must be the fixed-offset Etc/GMT-10
  expect_equal(
    attr(df$datetime, "tzone"), "Etc/GMT-10",
    label = "NEM datetime timezone"
  )

  # The UTC offset in the formatted output must always be +1000, never +1100.
  # If Australia/Sydney were used, January datetimes would show +1100 (AEDT).
  offsets <- unique(format(df$datetime, "%z"))
  expect_equal(
    offsets, "+1000",
    label = "NEM UTC offset must be fixed +1000 in January (no DST shift to +1100)"
  )
})


# --- WEM ---------------------------------------------------------------

test_that("WEM datetimes are in Australia/Perth (UTC+8, no DST)", {
  skip_if_no_api_key()

  df <- oe_get_network_data(
    network_code = "WEM",
    metrics      = "energy",
    interval     = "1d",
    date_start   = DATE_START,
    date_end     = DATE_END
  )

  expect_s3_class(df$datetime, "POSIXct")

  expect_equal(
    attr(df$datetime, "tzone"), "Australia/Perth",
    label = "WEM datetime timezone"
  )

  # Perth is always UTC+8 with no DST — offset must always be +0800
  offsets <- unique(format(df$datetime, "%z"))
  expect_equal(
    offsets, "+0800",
    label = "WEM UTC offset must be fixed +0800"
  )
})


# --- AEMO_ROOFTOP ------------------------------------------------------
# TODO: The network data endpoint currently returns 400 ("Network not supported")
# for AEMO_ROOFTOP. Re-enable this test once the API supports it.

# test_that("AEMO_ROOFTOP datetimes are in fixed UTC+10 (Etc/GMT-10)", {
#   skip_if_no_api_key()
#
#   df <- oe_get_network_data(
#     network_code = "AEMO_ROOFTOP",
#     metrics      = "energy",
#     interval     = "1d",
#     date_start   = DATE_START,
#     date_end     = DATE_END
#   )
#
#   expect_s3_class(df$datetime, "POSIXct")
#
#   expect_equal(
#     attr(df$datetime, "tzone"), "Etc/GMT-10",
#     label = "AEMO_ROOFTOP datetime timezone"
#   )
#
#   offsets <- unique(format(df$datetime, "%z"))
#   expect_equal(
#     offsets, "+1000",
#     label = "AEMO_ROOFTOP UTC offset must be fixed +1000"
#   )
# })


# --- APVI --------------------------------------------------------------
# TODO: The network data endpoint currently returns 400 ("Network not supported")
# for APVI. Re-enable this test once the API supports it.

# test_that("APVI datetimes are in fixed UTC+10 (Etc/GMT-10)", {
#   skip_if_no_api_key()
#
#   df <- oe_get_network_data(
#     network_code = "APVI",
#     metrics      = "energy",
#     interval     = "1d",
#     date_start   = DATE_START,
#     date_end     = DATE_END
#   )
#
#   expect_s3_class(df$datetime, "POSIXct")
#
#   expect_equal(
#     attr(df$datetime, "tzone"), "Etc/GMT-10",
#     label = "APVI datetime timezone"
#   )
#
#   offsets <- unique(format(df$datetime, "%z"))
#   expect_equal(
#     offsets, "+1000",
#     label = "APVI UTC offset must be fixed +1000"
#   )
# })


# --- UTC moment correctness (NEM) --------------------------------------

test_that("NEM datetime UTC values are numerically correct", {
  skip_if_no_api_key()

  # Fetch a single day at hourly resolution.
  # NEM midnight on 2025-01-06 in UTC+10 = 2025-01-05 14:00:00 UTC
  df <- oe_get_network_data(
    network_code = "NEM",
    metrics      = "energy",
    interval     = "1h",
    date_start   = "2025-01-06",
    date_end     = "2025-01-07"
  )

  expect_s3_class(df$datetime, "POSIXct")

  # The earliest timestamp should be midnight NEM time (00:00 +10:00),
  # which is 14:00 UTC on the *previous* day.
  first_dt  <- min(df$datetime)
  first_utc <- as.POSIXct(format(first_dt, tz = "UTC"), tz = "UTC")

  expect_equal(
    as.integer(format(first_utc, "%H")), 14L,
    label = "NEM midnight (+10:00) should be 14:00 UTC"
  )
})


# --- UTC moment correctness (WEM) --------------------------------------

test_that("WEM datetime UTC values are numerically correct", {
  skip_if_no_api_key()

  # WEM midnight on 2025-01-06 in UTC+8 = 2025-01-05 16:00:00 UTC
  df <- oe_get_network_data(
    network_code = "WEM",
    metrics      = "energy",
    interval     = "1h",
    date_start   = "2025-01-06",
    date_end     = "2025-01-07"
  )

  expect_s3_class(df$datetime, "POSIXct")

  first_dt  <- min(df$datetime)
  first_utc <- as.POSIXct(format(first_dt, tz = "UTC"), tz = "UTC")

  expect_equal(
    as.integer(format(first_utc, "%H")), 16L,
    label = "WEM midnight (+08:00) should be 16:00 UTC"
  )
})
