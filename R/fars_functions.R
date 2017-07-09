#' Function to read Fatality Analysis Reporting System (FARS) data files
#'
#' FARS is a nationwide census providing NHTSA, Congress and the American public yearly data regarding fatal injuries suffered in motor vehicle traffic crashes
#' The data files are in CSV format, often compressed. Function could read CSV and BZ2 files as well.
#' It has 50 variables=columns (eg. STATE, CITY, COUNTY, DAY, MONTH, YEAR, FATALS etc.), and around 30k records.
#'
#'
#' @note 	Existence of the file is checked at runtime. Internally read_csv function is used, which is part of package "readr", and need to be installed beforehand.
#' Second package dependence is dplyr, which is used for formatting output data.frame.
#'
#'
#'@source website \url{http://www-fars.nhtsa.dot.gov/Main/index.aspx}
#'
#' @param filename CSV or CSV.BZ2 filename with path leading to it as Character.
#'
#' @return A tibble (tbl_df, tbl, data.frame) containing the FARS dataset

#'
#' @importFrom   dplyr         tbl_df
#' @importFrom   readr         read_csv
#'
#' @keywords FARS, NHTSA, Road traffic safety
#'
#' @export
#' @examples
#' \dontrun{fars_file<-fars_read("path_to_your_file")}
#' \dontrun{summary(fars_file)}
#'
fars_read <- function(filename) {
  if(!file.exists(filename))
    stop("file '", filename, "' does not exist")
  data <- suppressMessages({
    readr::read_csv(filename, progress = FALSE)
  })
  dplyr::tbl_df(data)
}

#' Making FARS filenames from given YEAR
#'
#' Replacing percent \%d with year (given as input parameter) in string "accident_\%d.csv.bz2"
#'
#' @note 	Year is converted to integer internally.
#' We don't need to export it, as it's use case is mainly in functions from package
#'
#' @source Coursera, Building R Packages
#'
#' @param year A vector of years, provided as integers (1984)
#'   or strings ("1984", "2001"). Do not provide R 'Date' objects or shortened
#'   suffixes (eg 84) for a year.
#'
#' @return A vector of FARS filenames.
#'
#' @keywords FARS, NHTSA, Road traffic safety
#'
#' @export
#' @examples
#' make_filename(c(2012,2013)) #[1] "accident_2012.csv.bz2" "accident_2013.csv.bz2"
make_filename <- function(year) {
  year <- as.integer(year)
  sprintf("accident_%d.csv.bz2", year)
}

#' Reading FARS files
#'
#' Reading FARS files from working directory with given YEARS argument into tbl_df object of dplyr package.
#' Returns data from which  all variables(columns) except YEAR and MONTH are removed.
#' After reading the files dplyr with pipes(magrittr) are used to create new column year, and then remove all columns, except MONTH and YEAR.
#'
#' @note 	Function use make_filename(year) and fars_read(year) functions, and readr, dplyr and  magrittr packages.
#'
#' @source Coursera, Building R Packages
#'
#' @param years A vector of years, provided as a character vector or as an integer vector.
#' Provide the years in 4-digit format to ensure the correct file can be found for that year.
#' If any of the years is absent from the FARS dataset, a NULL value is returned for that year.
#' Files need to be in working directory.
#'
#' @return A list of tibble data-frames containing the FARS dataset for
#'   each year in the input set. The entry is NULL for any year that is absent
#'   from the FARS dataset.
#'
#' @importFrom   dplyr         mutate   select
#' @importFrom   magrittr      %>%
#'
#' @keywords FARS, NHTSA, Road traffic safety
#'
#' @export
#' @examples
#' setwd(dirname(system.file("extdata","accident_2013.csv.bz2",package = "fars")))
#' fry<-fars_read_years(c(2013))
#' str(fry)
#' summary(fry)
#' fry[1]
fars_read_years <- function(years) {
  lapply(years, function(year) {
    file <- make_filename(year)

    tryCatch({
      dat <- fars_read(file)
      #browser()
      dplyr::mutate(dat, year = "year") %>%
        dplyr::select("MONTH", "year")
    }, error = function(e) {
      warning("invalid year: ", year)
      return(NULL)
    })
  })
}

#' Shows how many FARS accidents happen in every month of given years.
#'
#' Reading FARS files from working directory with given YEARS argument into tbl_df objects which are then put into list.
#' After reading the files dplyr with pipes(magrittr) are used to summarize how many accidents happended in each month of year.
#'
#' @note 	Uses make_filename(year) and fars_read(year) and fars_read_years(years) functions, and readr, dplyr and  magrittr packages.
#'
#' @source Coursera, Building R Packages
#'
#' @param years A vector of years, provided as integers or
#'   strings. Only those entries that are present in the FARS data provide any
#'   valid returned data.
#'
#' @return A tibble containing the count of fatalities in the FARS data
#'   for each month and year. If all of the years are absent from the FARS data
#'   a NULL value is returned.
#'
#' @importFrom   magrittr      %>%
#' @importFrom   dplyr         bind_rows   group_by   summarize
#' @importFrom   tidyr         spread
#'
#' @keywords FARS, NHTSA, Road traffic safety
#'
#' @export
#' @examples
#' \dontrun{fsy<-fars_summarize_years(c(2013,2014,2015))}
#' \dontrun{fsy }
fars_summarize_years <- function(years) {
  year<-NULL
  MONTH<-NULL
  n<-NULL

  dat_list <- fars_read_years(years)
  dplyr::bind_rows(dat_list) %>%
    dplyr::group_by(year, MONTH) %>%
    dplyr::summarize(n = n()) %>%
    tidyr::spread(year, n)
}
#' Overlay accidents locations onto map of given state in given year
#'
#' The accident locations are plotted on the map of STATE given as input argument (integer).
#' Function checks whether there is such STATE for given YEAR, and throws "invalid STATE number" if it is missing.
#' If there are no accidents for given state, then "no accidents to plot" information is presented.
#' Read single FARS file from working directory with given YEAR argument into tbl_df objects.
#'
#'
#' @note \itemize{ \item State number 2 do not work: "nothing to draw: all regions out of bounds". Possible bug
#' \item If LONGITUD is bigger than 900 or LATITUDE bigger than 90, their value is set to NA.
#' \item Function uses make_filename(year) and fars_read(year) functions, and readr, dplyr, and maps packages.
#' \item See also \code{fars_read}
#' }
#'
#' @source Coursera, Building R Packages
#'
#' @param year A \code{Year} provided as a string or an integer. If
#'   the year is absent from the FARS data, this throws an error.
#'
#' @param state.num the index number of a state as an integer corresponding to a required state.
#'   The function throws an error if no fatality information is available for
#'   the requested state in the FARS data for the requested year.
#'
#' @return NULL return value. The function plots a graph as a side-effect
#'   If no accidents were observed in the state/year, no map is plotted.
#'
#' @importFrom   dplyr         filter
#' @importFrom   maps          map
#' @importFrom   graphics      points
#'
#' @keywords FARS, NHTSA, Road traffic safety
#'
#' @export
#'
#' @examples
#' \dontrun{ fars_map_state(44,2013)}
#' \dontrun{fars_map_state(2,2015)} # do not works for this year and 2013,2014 as well.
#' \dontrun{#Returns: nothing to draw: all regions out of bounds}
#'
fars_map_state <- function(state.num, year) {
  filename <- make_filename(year)
  data <- fars_read(filename)
  state.num <- as.integer(state.num)
  STATE<- NULL

  if(!(state.num %in% unique(data$STATE)))
    stop("invalid STATE number: ", state.num)
  data.sub <- dplyr::filter(data, STATE == state.num)
  if(nrow(data.sub) == 0L) {
    message("no accidents to plot")
    return(invisible(NULL))
  }
  is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
  is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
  with(data.sub, {
    maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
              xlim = range(LONGITUD, na.rm = TRUE))
    graphics::points(LONGITUD, LATITUDE, pch = 46)
  })
}
