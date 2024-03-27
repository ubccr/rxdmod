test_that("xdmod_get_datawarehouse/xdmod_get_data", {
  # get connector
  dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')
  expect_equal(is.null(dw), FALSE)
  # get data
  df <- xdmod_get_data(dw,
                       duration=c('2023-01-01', '2023-01-07'),
                       realm='Jobs',
                       metric='Number of Users: Active'
  )
  # compare to previous record
  df_check <- structure(list(
    Time = structure(c(19358, 19359, 19360, 19361, 19362, 19363, 19364),
                     class = "Date"),
    `Number of Users: Active` = c(378, 459, 555, 618, 633, 645, 485)),
    class = c("tbl_df", "tbl", "data.frame"),
    row.names = c(NA, -7L))
  expect_equal(df,df_check)
})
