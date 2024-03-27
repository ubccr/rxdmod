


#' Get XDMoD data-warehouse connector
#'
#' Get XDMoD data-warehouse connector.
#' Enviroment variable `XDMOD_API_TOKEN` should contain XDMoD API token.
#'
#' Get the token from your XDMoD instance and store in ~/.Renviron (~/Documents/.Renviron on windows) as:
#'
#' `XDMOD_API_TOKEN=<secret key>`
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
    dimension='None',
    filters=list(),
    dataset_type='timeseries',
    aggregation_unit='Auto'
) {
  # @TODO: check duration format
  with(datawarehouse$datawarehouse, {
    df <- datawarehouse$datawarehouse$get_data(
      duration=duration,
      realm=realm,
      metric=metric,
      dimension=dimension,
      filters=list(),
      dataset_type=dataset_type,
      aggregation_unit=aggregation_unit
    )})
  df <- df$reset_index()
  df$Time <- df$Time$dt$strftime('%Y/%m/%d')
  df <- reticulate::py_to_r(df)
  attr(df,'pandas.index') <- NULL
  df |> tibble::tibble() |> # use newer data.frame
    dplyr::mutate(Time=lubridate::ymd(Time)) # convert character to date
}
