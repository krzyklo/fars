% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{fars_summarize_years}
\alias{fars_summarize_years}
\title{Shows how many FARS accidents happen in every month of given years.}
\source{
Coursera, Building R Packages
}
\usage{
fars_summarize_years(years)
}
\arguments{
\item{years}{A vector of years, provided as integers or
strings. Only those entries that are present in the FARS data provide any
valid returned data.}
}
\value{
A tibble containing the count of fatalities in the FARS data
  for each month and year. If all of the years are absent from the FARS data
  a NULL value is returned.
}
\description{
Reading FARS files from working directory with given YEARS argument into tbl_df objects which are then put into list.
After reading the files dplyr with pipes(magrittr) are used to summarize how many accidents happended in each month of year.
}
\note{
Uses make_filename(year) and fars_read(year) and fars_read_years(years) functions, and readr, dplyr and  magrittr packages.
}
\examples{
\dontrun{fsy<-fars_summarize_years(c(2013,2014,2015))}
\dontrun{fsy }
}
\keyword{FARS,}
\keyword{NHTSA,}
\keyword{Road}
\keyword{safety}
\keyword{traffic}
