---
title: "Fatality Analysis Reporting System (FARS) with R programming language"
author: "Krzysztof Klos"
date: "2017-07-03"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Fatality Analysis Reporting System (FARS) with R programming language}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---
[![Build Status](https://travis-ci.org/krzyklo/fars.svg?branch=master)](https://travis-ci.org/krzyklo/fars)

FARS is a nationwide census providing NHTSA, Congress and the American public yearly data regarding fatal injuries suffered in motor vehicle traffic crashes.
The data files are in CSV format, often compressed. Function could read CSV and BZ2 files as well.
It has 50 variables=columns (eg. STATE, CITY, COUNTY, DAY, MONTH, YEAR, FATALS etc.), and around 30k records.
This `html_vignette` for FARS package shows basic usage of the functions provided.

## Installation
`devtools::install_github("krzyklo/fars")`

## Vignette Info
This package provides 5 R language functions for working with FARS data:

- fars_read
- make_filename
- fars_read_years
- fars_summarize_years
- fars_map_state

Below we could see the location of the FARS file attached to this package.


```r
library("fars")
fars2013_path<-system.file("extdata","accident_2013.csv.bz2",package = "fars")
fars2013_path
```

```
## [1] "/home/krzys/R/x86_64-pc-linux-gnu-library/3.2/fars/extdata/accident_2013.csv.bz2"
```

```r
getwd()
```

```
## [1] "/home/krzys/R/build_packages/fars/vignettes"
```

Function `fars_summarize_years()` shows summary for given years for each month in table.

| MONTH| year|
|-----:|----:|
|     1| 2230|
|     2| 1952|
|     3| 2356|
|     4| 2300|
|     5| 2532|
|     6| 2692|
|     7| 2660|
|     8| 2899|
|     9| 2741|
|    10| 2768|
|    11| 2615|
|    12| 2457|
Summary of fatalities for each month of 2013 year. 

Function `fars_map_state` shows accidents locations on the map:
![Fatalities map for year 2013 and state 1](figure/unnamed-chunk-3-1.png)
