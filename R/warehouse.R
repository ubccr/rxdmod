#' Get XDMoD data-warehouse connector
#'
#' Get XDMoD data-warehouse connector.
#' Enviroment variable `XDMOD_API_TOKEN` should contain XDMoD API token.
#'
#' Get the token from your XDMoD instance and store in ~/.Renviron (~/Documents/.Renviron on windows) as:
#'
#' `XDMOD_API_TOKEN=<secret key>`
#'
#' `vignette("XDMoD-Data-First-Example")`
#'
#' @param xdmod_host URL to XDMoD instance, for example 'https://xdmod.access-ci.org'
#'
#' @return XDMoD connector
#' @export
#'
#' @examples
#' dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')
#' df <- xdmod_get_data(dw,
#'     duration=c('2023-01-01', '2023-04-30'),
#'     realm='Jobs',
#'     metric='Number of Users: Active'
#'     )
#'
xdmod_get_datawarehouse <- function(xdmod_host) {
    # check that we can load and print good message
    warehouse <- reticulate::import("xdmod_data.warehouse",convert=FALSE)
    datawarehouse <- warehouse$DataWarehouse(xdmod_host)
    # datawarehouse$`__http_requester`$`__headers`['User-Agent'] <- paste0(datawarehouse$`__http_requester`$`__headers`['User-Agent'],"(RXDMoD v",rxdmod_version,")")
    list(datawarehouse=datawarehouse)
}


#' Get XDMoD data
#'
#' Get XDMoD data.
#' Enviroment variable `XDMOD_API_TOKEN` should contain XDMoD API token.
#'
#' Get the token from your XDMoD instance and store in ~/.Renviron (~/Documents/.Renviron on windows) as:
#'
#' `XDMOD_API_TOKEN=<secret key>`
#'
#' @param datawarehouse XDMoD connector
#' @param duration
#' @param realm
#' @param metric
#' @param dimension
#' @param filters
#' @param dataset_type
#' @param aggregation_unit
#'
#' @return data frame with requested data
#' @export
#'
#' @examples
#' dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')
#' df <- xdmod_get_data(dw,
#'     duration=c('2023-01-01', '2023-04-30'),
#'     realm='Jobs',
#'     metric='Number of Users: Active'
#'     )
#'
xdmod_get_data <- function(
    datawarehouse,
    duration='Previous month',
    realm='Jobs',
    metric='CPU Hours: Total',
    dimension=NULL,
    filters=NULL,
    dataset_type='timeseries',
    aggregation_unit='Auto',
    strings_as_factors=FALSE
) {
  # @TODO: check duration format
  if(!is.null(dimension)) {
    m_dimension <- dimension
  } else {
    m_dimension <- "None"
  }

  if(!is.null(filters)) {
    m_filters <- filters
  } else {
    m_filters <- list()
  }


  with(datawarehouse$datawarehouse, {
    df <- datawarehouse$datawarehouse$get_data(
      duration=duration,
      realm=realm,
      metric=metric,
      dimension=m_dimension,
      filters=m_filters,
      dataset_type=dataset_type,
      aggregation_unit=aggregation_unit
    )})
  df <- df$reset_index()
  df$Time <- df$Time$dt$strftime('%Y/%m/%d')
  df <- reticulate::py_to_r(df)
  # no need for pandas.index it was already df$reset_index()
  attr(df,'pandas.index') <- NULL
  df <- df |> tibble::tibble() |> # use newer data.frame
    dplyr::mutate(Time=lubridate::ymd(Time)) # convert character to date

  if(!is.null(dimension)) {
    df <- df |> pivot_longer(-Time, names_to=dimension, values_to=metric)

    if(strings_as_factors) {
      df[dimension] <- as.factor(df[dimension])
    }
  }

  df
}
