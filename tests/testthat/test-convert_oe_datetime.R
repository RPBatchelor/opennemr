library(testthat)
library(opennemr)

test_that("convert_oe_datetime handles basic ISO 8601 format with +10:00 offset", {
  # Test single datetime string with +10:00 offset (Sydney time)
  dt_string <- "2024-12-04T19:45:00+10:00"
  result <- convert_oe_datetime(dt_string)

  # Should return POSIXct
  expect_s3_class(result, "POSIXct")

  # Should have length 1
  expect_length(result, 1)

  # Should not be NA
  expect_false(is.na(result))
})

test_that("convert_oe_datetime handles different timezone offsets", {
  # Test +10:00 (Sydney)
  dt_sydney <- "2024-12-04T12:00:00+10:00"
  result_sydney <- convert_oe_datetime(dt_sydney)
  expect_s3_class(result_sydney, "POSIXct")

  # Test +08:00 (Perth)
  dt_perth <- "2024-12-04T12:00:00+08:00"
  result_perth <- convert_oe_datetime(dt_perth)
  expect_s3_class(result_perth, "POSIXct")

  # Test negative offset (e.g., US timezone)
  dt_negative <- "2024-12-04T12:00:00-05:00"
  result_negative <- convert_oe_datetime(dt_negative)
  expect_s3_class(result_negative, "POSIXct")

  # The actual time in UTC should differ based on offset
  # +10:00 means UTC is 10 hours behind, so 12:00+10:00 = 02:00 UTC
  # +08:00 means UTC is 8 hours behind, so 12:00+08:00 = 04:00 UTC
  expect_true(as.numeric(result_sydney) < as.numeric(result_perth))
})

test_that("convert_oe_datetime applies network timezone correctly", {
  dt_string <- "2024-12-04T12:00:00+10:00"

  # Test with NEM (should use Australia/Sydney)
  result_nem <- convert_oe_datetime(dt_string, network_code = "NEM")
  expect_equal(attr(result_nem, "tzone"), "Australia/Sydney")

  # Test with WEM (should use Australia/Perth)
  result_wem <- convert_oe_datetime(dt_string, network_code = "WEM")
  expect_equal(attr(result_wem, "tzone"), "Australia/Perth")

  # Test with AEMO_ROOFTOP (should use Australia/Sydney)
  result_aemo <- convert_oe_datetime(dt_string, network_code = "AEMO_ROOFTOP")
  expect_equal(attr(result_aemo, "tzone"), "Australia/Sydney")

  # Test with APVI (should use Australia/Sydney)
  result_apvi <- convert_oe_datetime(dt_string, network_code = "APVI")
  expect_equal(attr(result_apvi, "tzone"), "Australia/Sydney")
})

test_that("convert_oe_datetime handles vectorized input", {
  # Test multiple datetime strings
  dt_vector <- c(
    "2024-12-04T12:00:00+10:00",
    "2024-12-04T13:00:00+10:00",
    "2024-12-04T14:00:00+10:00",
    "2024-12-04T15:00:00+10:00"
  )

  result <- convert_oe_datetime(dt_vector, network_code = "NEM")

  # Should return vector of same length
  expect_length(result, 4)

  # All should be POSIXct
  expect_s3_class(result, "POSIXct")

  # Times should be sequential (1 hour apart)
  time_diffs <- diff(as.numeric(result))
  expect_equal(time_diffs, rep(3600, 3))  # 3600 seconds = 1 hour
})

test_that("convert_oe_datetime handles empty and NA inputs", {
  # Empty character vector
  result_empty <- convert_oe_datetime(character(0))
  expect_length(result_empty, 0)
  expect_s3_class(result_empty, "POSIXct")

  # NA value
  result_na <- convert_oe_datetime(NA_character_)
  expect_length(result_na, 1)
  expect_true(is.na(result_na))

  # Vector with NA
  dt_with_na <- c("2024-12-04T12:00:00+10:00", NA_character_, "2024-12-04T14:00:00+10:00")
  result_with_na <- convert_oe_datetime(dt_with_na)
  expect_length(result_with_na, 3)
  expect_false(is.na(result_with_na[1]))
  expect_true(is.na(result_with_na[2]))
  expect_false(is.na(result_with_na[3]))
})

test_that("convert_oe_datetime preserves correct time values", {
  # Test a known datetime conversion
  # 2024-12-04 12:00:00 +10:00 should be 2024-12-04 02:00:00 UTC
  dt_string <- "2024-12-04T12:00:00+10:00"
  result <- convert_oe_datetime(dt_string)

  # Convert to UTC to check actual time
  result_utc <- as.POSIXct(format(result, tz = "UTC"), tz = "UTC")

  # Extract hour (should be 02:00 UTC)
  hour_utc <- as.numeric(format(result_utc, "%H"))
  expect_equal(hour_utc, 2)
})

test_that("convert_oe_datetime handles realistic API response data", {
  # Simulate actual data from API response (from user's example)
  api_datetimes <- c(
    "2025-12-04T19:45:00+10:00",
    "2025-12-04T19:50:00+10:00",
    "2025-12-04T19:55:00+10:00",
    "2025-12-04T20:00:00+10:00"
  )

  result <- convert_oe_datetime(api_datetimes, network_code = "NEM")

  # Should convert all successfully
  expect_length(result, 4)
  expect_s3_class(result, "POSIXct")
  expect_true(all(!is.na(result)))

  # Should be in Australia/Sydney timezone
  expect_equal(attr(result, "tzone"), "Australia/Sydney")

  # Should be 5-minute intervals
  time_diffs <- diff(as.numeric(result))
  expect_equal(time_diffs, rep(300, 3))  # 300 seconds = 5 minutes
})

test_that("convert_oe_datetime handles unknown network codes gracefully", {
  dt_string <- "2024-12-04T12:00:00+10:00"

  # Unknown network code should fall back to UTC
  result <- convert_oe_datetime(dt_string, network_code = "UNKNOWN")
  expect_s3_class(result, "POSIXct")
  expect_equal(attr(result, "tzone"), "UTC")
})

test_that("convert_oe_datetime with NULL network_code uses UTC", {
  dt_string <- "2024-12-04T12:00:00+10:00"

  # NULL network_code should use UTC
  result <- convert_oe_datetime(dt_string, network_code = NULL)
  expect_s3_class(result, "POSIXct")
  expect_equal(attr(result, "tzone"), "UTC")
})

test_that("convert_oe_datetime handles different time components correctly", {
  # Test various times throughout the day
  # Note: December in Australia is summer, so Sydney is UTC+11 (DST)
  # The input times have +10:00 offset, so when converted to Sydney timezone
  # they will be displayed as 1 hour ahead
  times <- c(
    "2024-12-04T00:00:00+10:00",  # Midnight in +10
    "2024-12-04T06:30:15+10:00",  # Morning with seconds
    "2024-12-04T12:00:00+10:00",  # Noon in +10
    "2024-12-04T18:45:30+10:00",  # Evening
    "2024-12-04T23:00:00+10:00"   # Late evening
  )

  result <- convert_oe_datetime(times, network_code = "NEM")

  # All should convert successfully
  expect_length(result, 5)
  expect_true(all(!is.na(result)))
  expect_s3_class(result, "POSIXct")

  # Times are preserved correctly - the function preserves the actual instant in time
  # Check that times are in chronological order
  expect_true(all(diff(as.numeric(result)) > 0))
})
