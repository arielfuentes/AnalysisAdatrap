bimap <- function(df, Per){
  #libraries
  library(ggplot2)
  library(ggmap)
  library(cowplot)
  library(sf)
  library(biscale)
  library(ggspatial)
  ################
  #data
  SB_df <- filter(.data = df, Periodo == Per) %>%
    st_transform(4326) %>%
    bi_class(x = "DdaBaj", y = "DdaSub", style = "quantile", dim = 3) %>%
    rename(SubeBaja = bi_class)
#########################
#mapping
 #bbox
  bbox <- st_bbox(SB_df)
  names(bbox) <- c("left", "bottom", "right", "top")
  map <- ggmap(get_stamenmap(bbox, zoom = 11, maptype = "watercolor")) + 
    geom_sf(data = SB_df, 
            mapping = aes(fill = SubeBaja), 
            show.legend = F, 
            inherit.aes = F, 
            alpha = 0.8) +
    bi_scale_fill(pal = "DkBlue", dim = 3) +
    labs(title = "Sube-Baja por Zona", 
         subtitle = Per) +
    theme(panel.background = element_rect(fill = "white"),
          panel.border = element_rect(colour = "black", fill = NA), 
          axis.text.x = element_text(size = 8), 
          axis.text.y = element_text(size = 8)) +
    annotation_north_arrow(which_north = T, 
                           height = unit(1.5, "cm"), 
                           width = unit(1.5, "cm"), 
                           location = "tl", 
                           style = north_arrow_nautical) +
    annotation_scale()
#legend
legend <- bi_legend(pal = "DkBlue", dim = 3, xlab = "DdaBaj", ylab = "DdaSub", size = 8)
#final plot
mapf <- ggdraw() +
  draw_plot(map, 0,0,0.78,1) +
  draw_plot(legend, 0.85, 0.2, 0.1,0.1,scale = 2.5)
#plot saving
ggsave(plot = mapf, 
       filename = paste0("output/plot/", SB_df$NDía, "_", Per, "bimapa", ".png"), 
       device = "png", 
       dpi = 1000)
}
