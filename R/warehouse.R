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


#' Title
#'
#' @param datawarehouse
#'
#' @return
#' @export
#'
#' @examples
xdmod_get_durations <- function(datawarehouse) {
  with(datawarehouse$datawarehouse, {
    durations <- datawarehouse$datawarehouse$get_durations()
  })
  unlist(reticulate::py_to_r(durations))
}

#' Title
#'
#' @param datawarehouse
#'
#' @return
#' @export
#'
#' @examples
xdmod_describe_realms <- function(datawarehouse) {
  with(datawarehouse$datawarehouse, {
    realms <- datawarehouse$datawarehouse$describe_realms()
  })
  reticulate::py_to_r(realms$reset_index()) %>% tibble::tibble()
}

#' Title
#'
#' @param datawarehouse
#' @param realm
#'
#' @return
#' @export
#'
#' @examples
xdmod_describe_metrics <- function(datawarehouse, realm) {
  with(datawarehouse$datawarehouse, {
    metrics <- datawarehouse$datawarehouse$describe_metrics(realm)
  })
  reticulate::py_to_r(metrics$reset_index()) %>% tibble::tibble()
}

#' Title
#'
#' @param datawarehouse
#' @param realm
#'
#' @return
#' @export
#'
#' @examples
xdmod_describe_dimensions <- function(datawarehouse, realm) {
  with(datawarehouse$datawarehouse, {
    dimensions = datawarehouse$datawarehouse$describe_dimensions(realm)
  })
  reticulate::py_to_r(dimensions$reset_index()) %>% tibble::tibble()
}

#' Title
#'
#' @param datawarehouse
#' @param realm
#' @param dimension
#'
#' @return
#' @export
#'
#' @examples
xdmod_get_filter_values <- function(datawarehouse, realm, dimension) {
  with(datawarehouse$datawarehouse, {
    filter_values <- datawarehouse$datawarehouse$get_filter_values(realm, dimension) }) # 'resource' also works
  reticulate::py_to_r(filter_values$reset_index()) %>% tibble::tibble()
}

#' Title
#'
#' @param datawarehouse
#'
#' @return
#' @export
#'
#' @examples
xdmod_get_aggregation_units <- function(datawarehouse) {
  with(datawarehouse$datawarehouse,{
    aggregation_units <- datawarehouse$datawarehouse$get_aggregation_units()})
  unlist(reticulate::py_to_r(aggregation_units))
}

raw_data_col_types <- list(
  'Accounts'=readr::cols_only(
    `Account Creation Date` = readr::col_datetime(format = ""),
    `User` = readr::col_character(),
    `Resource` = readr::col_character(),
    `Resource Type` = readr::col_character()
  ),
  'Jobs'=readr::cols_only(
    `Local Job Id` = readr::col_character(),
    `Resource` = readr::col_character(),
    `Timezone` = readr::col_character(),
    `System Username (Deidentified)` = readr::col_character(),
    `User` = readr::col_character(),
    `Organization` = readr::col_character(),
    `Submit Time (Timestamp)` = readr::col_double(),
    `Start Time (Timestamp)` = readr::col_double(),
    `End Time (Timestamp)` = readr::col_double(),
    `Nodes` = readr::col_double(),
    `Cores` = readr::col_double(),
    `Memory Used` = readr::col_double(),
    `Wall Time` = readr::col_double(),
    `Wait Time` = readr::col_double(),
    `Core Time` = readr::col_double(),
    `XD SUs Charged` = readr::col_double(),
    `ACCESS Credit Equivalents Charged` = readr::col_double(),
    `Queue` = readr::col_character(),
    `NSF Directorate` = readr::col_character(),
    `Parent Science` = readr::col_character(),
    `Field of Science` = readr::col_character()
  ),
  'SUPREMM'=readr::cols_only(
    `Local Job Id` = readr::col_character(), # there are [] for arrays?
    `System Username (Deidentified)` = readr::col_character(),
    `ACCESS Credit Equivalents Charged` = readr::col_double(),
    `Shared` = readr::col_logical(),
    `Cores` = readr::col_integer(),
    `Gpu Count` = readr::col_integer(),
    `Nodes` = readr::col_integer(),
    `Total Cores Available` = readr::col_integer(),
    `Cpu Time` = readr::col_double(),
    `Gpu Time` = readr::col_double(),
    `Node Time` = readr::col_double(),
    `Requested Nodes` = readr::col_integer(),
    `Requested Wall Time` = readr::col_double(),
    `Queue` = readr::col_character(),
    `Wait Time` = readr::col_double(),
    `Wall Time` = readr::col_double(),
    `Eligible Time (Timestamp)` = readr::col_double(),
    `End Time (Timestamp)` = readr::col_double(),
    `Start Time (Timestamp)` = readr::col_double(),
    `Submit Time (Timestamp)` = readr::col_double(),
    `Organization` = readr::col_character(),
    `Resource` = readr::col_character(),
    `Field of Science` = readr::col_character(),
    `PI` = readr::col_character(),
    `Timezone` = readr::col_character(),
    `User` = readr::col_character(),
    `User Institution` = readr::col_character(),
    `GPU usage` = readr::col_double(),
    `GPU average memory usage` = readr::col_double(),
    `CPU Idle` = readr::col_double(),
    `CPU System` = readr::col_double(),
    `CPU User` = readr::col_double(),
    `FLOPS` = readr::col_double(),
    `CPI (ref)` = readr::col_double(),
    `CPI (ref) cov` = readr::col_double(),
    `CPLD (ref)` = readr::col_double(),
    `CPLD (ref) cov` = readr::col_double(),
    `CPU User cov` = readr::col_double(),
    `FLOPS cov` = readr::col_double(),
    `Block device "sda" data read` = readr::col_double(),
    `Block device "sda" data written` = readr::col_double(),
    `Mount point "home" data read` = readr::col_double(),
    `Mount point "home" data written` = readr::col_double(),
    `Mount point "scratch" data read` = readr::col_double(),
    `Mount point "scratch" data written` = readr::col_double(),
    `Mount point "work" data read` = readr::col_double(),
    `Mount point "work" data written` = readr::col_double(),
    `Block device "sda" read operations` = readr::col_double(),
    `Block device "sda" write operations` = readr::col_double(),
    `Block device "sda" data read cov` = readr::col_double(),
    `Block device "sda" data written cov` = readr::col_double(),
    `Mount point "home" data written cov` = readr::col_double(),
    `Mount point "scratch" data written cov` = readr::col_double(),
    `Mount point "work" data written cov` = readr::col_double(),
    `Memory Transferred` = readr::col_double(),
    `Memory Used` = readr::col_double(),
    `Total memory used` = readr::col_double(),
    `Memory Transferred cov` = readr::col_double(),
    `Memory Used Cov` = readr::col_double(),
    `Peak Memory Usage Ratio` = readr::col_double(),
    `Total memory used cov` = readr::col_double(),
    `Ib Rx Bytes` = readr::col_double(),
    `Net Eth0 Rx` = readr::col_double(),
    `Net Eth0 Tx` = readr::col_double(),
    `Net Ib0 Rx` = readr::col_double(),
    `Net Ib0 Tx` = readr::col_double(),
    `Net Mic0 Rx` = readr::col_double(),
    `Net Mic0 Tx` = readr::col_double(),
    `Net Mic1 Rx` = readr::col_double(),
    `Net Mic1 Tx` = readr::col_double(),
    `Parallel filesystem lustre bytes received` = readr::col_double(),
    `Parallel filesystem lustre bytes transmitted` = readr::col_double(),
    `Parallel filesystem lustre messages received` = readr::col_double(),
    `Parallel filesystem lustre messages transmitted` = readr::col_double(),
    `Net Eth0 Rx Packets` = readr::col_double(),
    `Net Eth0 Tx Packets` = readr::col_double(),
    `Net Ib0 Rx Packets` = readr::col_double(),
    `Net Ib0 Tx Packets` = readr::col_double(),
    `Net Mic0 Rx Packets` = readr::col_double(),
    `Net Mic0 Tx Packets` = readr::col_double(),
    `Net Mic1 Rx Packets` = readr::col_double(),
    `Net Mic1 Tx Packets` = readr::col_double(),
    `Net Eth0 Rx Cov` = readr::col_double(),
    `Net Eth0 Tx Cov` = readr::col_double(),
    `Net Ib0 Rx Cov` = readr::col_double(),
    `Net Ib0 Tx Cov` = readr::col_double(),
    `Parallel filesystem lustre bytes transmitted cov` = readr::col_double()
  )
)

raw_data_timestamp_cols <- list(
  'Jobs'=c(
    'Submit Time (Timestamp)',
    'Start Time (Timestamp)',
    'End Time (Timestamp)'),
  'SUPREMM'=c(
    'Eligible Time (Timestamp)',
    'End Time (Timestamp)',
    'Start Time (Timestamp)',
    'Submit Time (Timestamp)')
)

raw_data_factors_cols <- list(
  'Accounts'=c(
    'User',
    'Resource',
    'Resource Type'
  ),
  'Jobs'=c(
    #'Local Job Id',
    'Resource',
    'Timezone',
    'System Username (Deidentified)',
    'User',
    'Organization',
    'Queue',
    'NSF Directorate',
    'Parent Science',
    'Field of Science'),
  'SUPREMM'=c(
    'System Username (Deidentified)',
    'Organization',
    'Resource',
    'Field of Science',
    'PI',
    'Timezone',
    'User',
    'User Institution'
  )
)

#' Title
#'
#' @param df
#' @param realm
#'
#' @return
#' @export
#'
#' @examples
xdmod_strings_as_factors <- function(df, realm) {
  if(realm %in% names(raw_data_factors_cols)) {
    conv_colnames <- intersect(raw_data_factors_cols[[realm]], colnames(df))
    if(length(conv_colnames)>0) {
      conv_cols <- df[conv_colnames]
      df[conv_colnames] <- lapply(seq_along(conv_cols), function(i) {
        as.factor(conv_cols[[i]])
      })
    }
  }
  df
}

#' Title
#'
#' @param datawarehouse
#' @param duration
#' @param realm
#' @param fields
#' @param filters
#' @param show_progress
#' @param convert_timestamp
#' @param tz
#' @param strings_as_factors
#'
#' @return
#' @export
#'
#' @examples
xdmod_get_raw_data <- function(
    datawarehouse,
    duration,
    realm,
    fields=NULL,
    filters=list(),
    show_progress=FALSE,
    convert_timestamp=TRUE,
    tz=NULL,
    strings_as_factors=FALSE
) {
  # strings_as_factors convert strings which has sense as factors to factors
  if(is.null(fields)) {
    fields <- py_eval("()")
  }
  with(datawarehouse$datawarehouse, {
    df <- datawarehouse$datawarehouse$get_raw_data(
      duration=duration,
      realm=realm,
      fields=fields,
      filters=filters,
      show_progress=show_progress
    )})
  df2 <- tibble::tibble(reticulate::py_to_r(df))
  if(realm %in% names(raw_data_col_types)) {
    df2<-readr::type_convert(df2,col_types=raw_data_col_types[[realm]])
  }
  if(convert_timestamp) {
    if(realm %in% names(raw_data_timestamp_cols)) {
      conv_colnames <- intersect(raw_data_timestamp_cols[[realm]], colnames(df2))
      if(length(conv_colnames)>0) {
        conv_cols <- df2[conv_colnames]
        df2[conv_colnames] <- lapply(seq_along(conv_cols), function(i) {
          lubridate::as_datetime(conv_cols[[i]],tz=tz)
        })
      }
    }
  }
  if(strings_as_factors) {
    df2 <- xdmod_strings_as_factors(df2, realm)
  }
  df2
}



#' Title
#'
#' @param datawarehouse
#'
#' @return
#' @export
#'
#' @examples
xdmod_describe_raw_realms <- function(datawarehouse) {
  with(datawarehouse$datawarehouse, {
    realms <- datawarehouse$datawarehouse$describe_raw_realms()
  })
  reticulate::py_to_r(realms$reset_index()) %>% tibble::tibble()
}

#' Title
#'
#' @param datawarehouse
#' @param realm
#'
#' @return
#' @export
#'
#' @examples
xdmod_describe_raw_fields <- function(datawarehouse, realm) {
  with(datawarehouse$datawarehouse, {
    metrics <- datawarehouse$datawarehouse$describe_raw_fields(realm)
  })
  reticulate::py_to_r(metrics$reset_index()) %>% tibble::tibble()
}

#' Title
#'
#' @param datawarehouse
#' @param realm
#'
#' @return
#' @export
#'
#' @examples
xdmod_describe_dimensions <- function(datawarehouse, realm) {
  with(datawarehouse$datawarehouse, {
    dimensions = datawarehouse$datawarehouse$describe_dimensions(realm)
  })
  reticulate::py_to_r(dimensions$reset_index()) %>% tibble::tibble()
}

#' Title
#'
#' @param datawarehouse
#' @param realm
#' @param dimension
#'
#' @return
#' @export
#'
#' @examples
xdmod_get_filter_values <- function(datawarehouse, realm, dimension) {
  with(datawarehouse$datawarehouse, {
    filter_values <- datawarehouse$datawarehouse$get_filter_values(realm, dimension) }) # 'resource' also works
  reticulate::py_to_r(filter_values$reset_index()) %>% tibble::tibble()
}

