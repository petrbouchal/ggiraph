
# create datasets -----
id = paste0("id", 1:10)
data = expand.grid(list(
	variable = c("2000", "2005", "2010", "2015"),
	id = id
	)
)
groups = sample(LETTERS[1:3], size = length(id), replace = TRUE)
data$group = groups[match(data$id, id)]
data$value = runif(n = nrow(data))
data$tooltip = paste0('line ', data$id )
data$onclick = paste0("alert(\"", data$id, "\")" )

cols = c("orange", "orange1", "orange2", "navajowhite4", "navy")
dataset2 <- data.frame(x = rep(1:20, 5),
		y = rnorm(100, 5, .2) + rep(1:5, each=20),
		z = rep(1:20, 5),
		grp = factor(rep(1:5, each=20)),
		color = factor(rep(1:5, each=20)),
		label = rep(paste0( "id ", 1:5 ), each=20),
		onclick = paste0(
		  "alert(\"",
		  sample(letters, 100, replace = TRUE),
		  "\")" )
)


# plots ---
gg_path_1 = ggplot(data, aes(variable, value, group = id,
		colour = group, tooltip = tooltip, onclick = onclick, data_id = id)) +
	geom_path_interactive(alpha = 0.5)

gg_path_2 = ggplot(data, aes(variable, value, group = id, data_id = id,
		tooltip = tooltip)) +
	geom_path_interactive(alpha = 0.5) +
	facet_wrap( ~ group )

gg_path_3 = ggplot(dataset2) +
	geom_path_interactive(aes(x, y, group=grp, data_id = label,
		color = color, tooltip = label, onclick = onclick), size = 1 )

# ggiraph widgets ---
ggiraph(code = {print(gg_path_1)}, hover_css = "stroke-width:3px;")
ggiraph(code = {print(gg_path_2)}, hover_css = "stroke:orange;stroke-width:3px;")
ggiraph(code = {print(gg_path_3)}, hover_css = "stroke-width:10px;")
