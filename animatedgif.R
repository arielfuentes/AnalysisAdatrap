library(magick)
imgs <- list.files("output/plot/")
imgs_lst <- lapply(X = imgs, FUN = function(x) image_scale(image_read(paste0("output/plot/", x)
                                                                      )
                                                           )
                   )
image_join(imgs_lst) %>%
image_animate(fps = 5) %>%  
  image_write("output/plot/periodos.gif")
