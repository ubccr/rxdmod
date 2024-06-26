% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/warehouse.R
\name{xdmod_get_data}
\alias{xdmod_get_data}
\title{Get XDMoD data}
\usage{
xdmod_get_data(
  datawarehouse,
  duration = "Previous month",
  realm = "Jobs",
  metric = "CPU Hours: Total",
  dimension = NULL,
  filters = NULL,
  dataset_type = "timeseries",
  aggregation_unit = "Auto",
  strings_as_factors = FALSE
)
}
\arguments{
\item{datawarehouse}{XDMoD connector}

\item{aggregation_unit}{}
}
\value{
data frame with requested data
}
\description{
Get XDMoD data.
Enviroment variable \code{XDMOD_API_TOKEN} should contain XDMoD API token.
}
\details{
Get the token from your XDMoD instance and store in ~/.Renviron (~/Documents/.Renviron on windows) as:

\verb{XDMOD_API_TOKEN=<secret key>}
}
\examples{
dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')
df <- xdmod_get_data(dw,
    duration=c('2023-01-01', '2023-04-30'),
    realm='Jobs',
    metric='Number of Users: Active'
    )

}
