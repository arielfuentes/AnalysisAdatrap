#parameters
DDBB_v <- "[082019viajes]"
zn_ipt <- "input/Zonas/natural_earth_10m_chile_provinces_utm19sPolygon.shp"
A4 <- "input/2019-07-06_consolidado_anexo4_(Circunvalación)_anual.xlsx"
nodos <- "input/dicc_nodoV2_2.csv"
#objects & functions calling
source("code/ipt.R", encoding = "UTF-8")
vjs_submd <- vjs_submd_fun(DDBB_v = DDBB_v)
SubeBaja <- SubeBaja_fun(DDBB_v = DDBB_v)
source("code/wrg_dt.R", encoding = "UTF-8")
source("code/bimap.R", encoding = "UTF-8")
lapply(X = Per$Periodo, function(x) bimap(df = sp_jn, Per = x))
source("code/animatedgif.R", encoding = "UTF-8")
mobility <- magick::image_read("output/plot/periodos.gif")
#markdown
rmarkdown::render(input = "code/Analisis_gnrl.Rmd", 
                  output_file = "Análisis_Adatrap", 
                  output_dir = "output/", 
                  encoding = "UTF-8")
