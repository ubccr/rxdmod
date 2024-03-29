
xdmod_colors <- c(
  "#1199FF",
  "#DB4230",
  "#4E665D",
  "#F4A221",
  "#66FF00",
  "#33ABAB",
  "#A88D95",
  "#789ABC",
  "#FF99CC",
  "#00CCFF",
  "#FFBC71",
  "#A57E81",
  "#8D4DFF",
  "#FF6666",
  "#CC99FF",
  "#2F7ED8",
  "#0D233A",
  "#8BBC21",
  "#910000",
  "#1AADCE",
  "#492970",
  "#F28F43",
  "#77A1E5",
  "#3366FF",
  "#FF6600",
  "#808000",
  "#CC99FF",
  "#008080",
  "#CC6600",
  "#9999FF",
  "#99FF99",
  "#969696",
  "#FF00FF",
  "#FFCC00",
  "#666699",
  "#00FFFF",
  "#00CCFF",
  "#993366",
  "#3AAAAA",
  "#C0C0C0",
  "#FF99CC",
  "#FFCC99",
  "#CCFFCC",
  "#CCFFFF",
  "#99CCFF",
  "#339966",
  "#FF9966",
  "#69BBED",
  "#33FF33",
  "#6666FF",
  "#FF66FF",
  "#99ABAB",
  "#AB8722",
  "#AB6565",
  "#990099",
  "#999900",
  "#CC3300",
  "#669999",
  "#993333",
  "#339966",
  "#C42525",
  "#A6C96A",
  "#111111"
)


#' XDMoD color palette (discrete)
#'
#' The Highcharts uses many different color palettes in its
#' plots. This collects a few of them.
#'
#' @param palette \code{character} The name of the xdmod theme to use. One of
#'  \code{"default"}, or \code{"darkunica"}.
#'
#' @family colour xdmod
#' @export
xdmod_pal <- function() {
  scales::manual_pal(xdmod_colors)
}

old_ggplot2_discrete_colour <- NULL

#' Set default option to use XDMoD pallet
#'
#' @return NULL
#' @export
#' @examples
#' xdmod_set_colors()
#'
#' dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')
#'
#' df <- xdmod_get_data(dw,
#'   duration=c('2023-01-01', '2023-03-31'),
#'   realm='Jobs',
#'   metric='CPU Hours: Total',
#'   dimension='Resource'
#' )
#'
#' ggplot(df,aes(x=Time, y=`CPU Hours: Total`, color=Resource)) + geom_line()
#'
#'
xdmod_set_colors <- function() {
  old_ggplot2_discrete_colour <- getOption("ggplot2.discrete.colour")
  options(ggplot2.discrete.colour = xdmod_colors)
}

#' Reset pallet to previous value
#'
#' @return NULL
#' @export
xdmod_reset_colors <- function() {
  options(ggplot2.discrete.colour = old_ggplot2_discrete_colour)
}

#' Set XDMoD-like theme
#'
#' Set XDMoD-like theme, which is just `ggplot2::theme_bw` at this point
#'
#' @param base_size
#' @param base_family
#' @param base_line_size
#' @param base_rect_size
#' @param set_colors set default colors to XDMoD pallet
#'
#' @return ggplot2 theme
#' @export
#'
#' @examples
#' theme_set(theme_xdmod(set_colors = T))
#'
#' dw <- xdmod_get_datawarehouse('https://xdmod.access-ci.org')
#'
#' df <- xdmod_get_data(dw,
#'   duration=c('2023-01-01', '2023-03-31'),
#'   realm='Jobs',
#'   metric='CPU Hours: Total',
#'   dimension='Resource'
#' )
#'
#' ggplot(df,aes(x=Time, y=`CPU Hours: Total`, color=Resource)) + geom_line()
#'
theme_xdmod <- function (base_size = 11, base_family = "", base_line_size = base_size/22,
                         base_rect_size = base_size/22, set_colors=T)
{
  tm <- ggplot2::theme_bw(base_size = base_size, base_family = base_family,
                 base_line_size = base_line_size, base_rect_size = base_rect_size)
  # %+replace%
  #     theme(panel.border = element_blank(), panel.grid.major = element_blank(),
  #         panel.grid.minor = element_blank(), axis.line = element_line(colour = "black",
  #             linewidth = rel(1)), legend.key = element_blank(),
  #         strip.background = element_rect(fill = "white",
  #             colour = "black", linewidth = rel(2)), complete = TRUE)
  if(set_colors) {
    xdmod_set_colors()
  }
  tm
}


#' XDMoD color and fill scales
#'
#' Colour and fill scales which use XDMoD the palettes
#'
#' @inheritParams ggplot2::scale_colour_hue
#' @inheritParams xdmod_pal
#' @family colour xdmod
#' @rdname scale_xdmod
#' @export
scale_colour_xdmod <- function(palette = "default", ...) {
  ggplot2::discrete_scale("colour", "xdmod", xdmod_pal(), ...)
}

#' @rdname scale_xdmod
#' @export
scale_color_xdmod <- scale_colour_xdmod

#' @rdname scale_xdmod
#' @export
scale_fill_xdmod <- function(palette = "default", ...) {
  ggplot2::discrete_scale("fill", "xdmod", xdmod_pal(), ...)
}
