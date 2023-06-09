% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert_on_datetime.R
\name{convert_on_datetime}
\alias{convert_on_datetime}
\title{Convert datetime format from OpenNEM into R friendly datetime format}
\usage{
convert_on_datetime(dt, return = "aware")
}
\arguments{
\item{dt}{datetime from OpenNEM API call}

\item{return}{R friendly datetime format}
}
\value{
datetime format for use within R
}
\description{
Convert datetime format from OpenNEM into R friendly datetime format
}
\examples{
\dontrun{
convert_on_datetime(dt = "2023-03-01Z 12:00:00T")
}
}
