
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RXDMoD - R API for XDMoD Data Analytics Framework

Version: 1.0.0

As part of the XDMoD Data Analytics Framework, this R package provides
API access to the data warehouse of an instance of XDMoD.

<!-- badges: start -->
<!-- badges: end -->

The goal of rxdmod is to …

## Installation

You can install the development version of rxdmod from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ubccr/rxdmod")
```

## Example

``` r
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.3     ✔ readr     2.1.4
#> ✔ forcats   1.0.0     ✔ stringr   1.5.0
#> ✔ ggplot2   3.4.4     ✔ tibble    3.2.1
#> ✔ lubridate 1.9.3     ✔ tidyr     1.3.0
#> ✔ purrr     1.0.2     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
library(plotly)
#> 
#> Attaching package: 'plotly'
#> 
#> The following object is masked from 'package:ggplot2':
#> 
#>     last_plot
#> 
#> The following object is masked from 'package:stats':
#> 
#>     filter
#> 
#> The following object is masked from 'package:graphics':
#> 
#>     layout

# replace xdmod-notebooks with conda enviroment for python to use
library(reticulate)
use_condaenv("xdmod-notebooks")

library(rxdmod)
```

``` r
# Get XDMoD connection
dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')

# Get Data of Interest
df <- xdmod_get_data(dw,
        duration=c('2023-01-01', '2023-03-31'),
        realm='Jobs',
        metric='Number of Users: Active'
    )
df |> head()
#> # A tibble: 6 × 2
#>   Time       `Number of Users: Active`
#>   <date>                         <dbl>
#> 1 2023-01-01                       378
#> 2 2023-01-02                       459
#> 3 2023-01-03                       555
#> 4 2023-01-04                       618
#> 5 2023-01-05                       633
#> 6 2023-01-06                       645
```

Plot the data

``` r
ggplot(df, aes(x=Time,y=`Number of Users: Active`)) +
        geom_line()
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
