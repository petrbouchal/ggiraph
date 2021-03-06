#' @import htmlwidgets
#' @import htmltools
#' @import rvg
#' @import grid
#' @importFrom grDevices dev.off
#' @importFrom xml2 read_xml
#' @importFrom xml2 xml_find_all
#' @importFrom xml2 xml_text
#' @importFrom xml2 xml_ns

#' @title ggiraph
#'
#' @description Create an interactive graphic
#' to be used in a web browser.
#'
#' @param code Plotting code to execute
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param width widget width
#' @param height widget height
#' @param tooltip_extra_css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param hover_css css to apply when mouse is hover and element with a data-id attribute.
#' @param tooltip_opacity tooltip opacity
#' @param tooltip_offx tooltip x offset
#' @param tooltip_offy tooltip y offset
#' @param zoom_max maximum zoom factor
#' @param zoompan should chart zoom and pan?
#' @param ... arguments passed on to \code{\link[rvg]{dsvg}}
#' @seealso \code{\link{geom_path_interactive}},
#' \code{\link{geom_point_interactive}},
#' \code{\link{geom_polygon_interactive}},
#' \code{\link{geom_rect_interactive}},
#' \code{\link{geom_segment_interactive}}
#' @examples
#' # ggiraph simple example -------
#' @example examples/geom_point_interactive.R
#' @export
ggiraph <- function(code,
	pointsize = 12, width = 6, height = 6,
	tooltip_extra_css,
	hover_css,
	tooltip_opacity = .9,
	tooltip_offx = 10,
	tooltip_offy = 0,
	zoom_max = 6,
	zoompan = T,
	...) {

  if( missing( tooltip_extra_css ))
    tooltip_extra_css <- "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;"
  if( missing( hover_css ))
    hover_css <- "fill:orange;"
  if(zoompan==F & !missing(zoom_max))
    warning("zoom_max has no effect when zoompan == F")

  stopifnot(is.numeric(tooltip_offx))
  stopifnot(is.numeric(tooltip_offy))
  stopifnot(is.numeric(tooltip_opacity))
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(is.numeric(zoom_max))
  stopifnot( zoom_max > 1 )

	ggiwid.options = getOption("ggiwid")
	tmpdir = tempdir()
	path = tempfile()
	canvas_id <- ggiwid.options$svgid
	dsvg(file = path, pointsize = pointsize, standalone = TRUE,
			width = width, height = height,
			canvas_id = canvas_id, ...
		)
	tryCatch(code, finally = dev.off() )

	ggiwid.options$svgid = 1 + ggiwid.options$svgid
	options("ggiwid"=ggiwid.options)

	svg_container <- paste( scan(path, what = "character", sep = "\n", quiet = TRUE), collapse = "")

	data <- read_xml( path )
	scr <- xml_find_all(data, "//*[@type='text/javascript']", ns = xml_ns(data) )
	js <- paste( sapply( scr, xml_text ), collapse = ";")

	unlink(path)

	data_id_class <- basename(tempfile(tmpdir = "", fileext = "", pattern = "cl"))

	if( grepl(x = tooltip_extra_css, pattern = "position[ ]*:") )
	  stop("please, do not specify position in tooltip_extra_css, this parameter is managed by ggiraph.")
	if( grepl(x = tooltip_extra_css, pattern = "pointer-events[ ]*:") )
	  stop("please, do not specify pointer-events in tooltip_extra_css, this parameter is managed by ggiraph.")

	x = list( html = HTML( svg_container ), code = js, canvas_id = ggiwid.options$svgid,
	          data_id_class = data_id_class,
	          tooltip_extra_css = tooltip_extra_css,
	          hover_css = hover_css,
	          tooltip_opacity = tooltip_opacity,
	          tooltip_offx = tooltip_offx,
	          tooltip_offy = tooltip_offy,
	          zoom_max = zoom_max,
	          zoompan = zoompan
	          )

	# create widget
	htmlwidgets::createWidget(
			name = 'ggiraph',
			x,
			width = NULL,
			height = NULL,
			package = 'ggiraph',
			sizingPolicy = sizingPolicy(padding = 0, browser.fill = TRUE )
	)
}

#' @title Create a ggiraph output element
#' @description Render a ggiraph within an application page.
#'
#' @param outputId output variable to read the ggiraph from.
#' @param width widget width
#' @param height widget height
#' @examples
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' @export
ggiraphOutput <- function(outputId, width = "100%", height = "500px"){
	shinyWidgetOutput(outputId, 'ggiraph', package = 'ggiraph', width = width, height = height)
}

#' @title Reactive version of ggiraph object
#'
#' @description Makes a reactive version of a ggiraph object for use in Shiny.
#'
#' @param expr An expression that returns a \code{\link{ggiraph}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @examples
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' @export
renderggiraph <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, ggiraphOutput, env, quoted = TRUE)
}
