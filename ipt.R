library(tidyr)
library(sf)
library(readxl)
library(dplyr)
library(readr)
library(stringr)
vjs_submd_fun <- function(DDBB_v){
  #libraries
  library(DBI)
  library(dtplyr)
  library(dplyr)
  library(data.table)
  #connection
  con <- DBI::dbConnect(odbc::odbc(),
                        Driver   = "SQL Server",
                        Server   = "22.222.222.22",
                        Database = "@@@@",
                        UID      = "ask user",
                        PWD      = "ask password",
                        encoding = "latin1")
  
  sql_vjs_submd <- paste0("SELECT [periodomediodeviaje] AS Periodo
,[tipodia] AS Día
,[netapa]
,[submodo_1era]
,[submodo_2da]
,[submodo_3era]
,[submodo_4ta]
,SUM([Demanda]) AS Demanda
FROM [Asig].[dbo].", DDBB_v, 
"GROUP BY [periodomediodeviaje]
,[tipodia]
,[netapa]
,[submodo_1era]
,[submodo_2da]
,[submodo_3era]
,[submodo_4ta];")
  
  vjs_submd <- lazy_dt(DBI::dbGetQuery(conn = con, 
                                       statement = sql_vjs_submd)
                       )

}
#########################
class_día <- tibble(Día = c("LABORAL", "SABADO", "DOMINGO"), 
                    NDía = c(1,2,3))
#########################
SubeBaja_fun <- function(DDBB_v){
  #libraries
  library(DBI)
  library(dtplyr)
  library(dplyr)
  library(data.table)
  #connection
  con <- DBI::dbConnect(odbc::odbc(),
                        Driver   = "SQL Server",
                        Server   = "10.222.128.21,9433",
                        Database = "uchile",
                        UID      = "sa",
                        PWD      = "Estudios2017..",
                        encoding = "latin1")
  
  sql_SubBaj <- paste0("SELECT [periodomediodeviaje] AS Periodo
  ,[tipodia] AS Día
  ,[paraderosubida]
  ,[paraderobajada]
  ,SUM([Demanda]) AS Demanda
  FROM [Asig].[dbo].", DDBB_v,
  "GROUP BY [periodomediodeviaje]
  ,[tipodia]
  ,[paraderosubida]
  ,[paraderobajada];")
  
  SubeBaja <- lazy_dt(DBI::dbGetQuery(conn = con,
                                      statement = sql_SubBaj)
                      )
}
########################
Per <- read_csv2(file = "input/periodos.csv")
########################
Zonas <- st_read(zn_ipt) %>%
  filter(name == "Region Metropolitana de Santiago") %>%
  st_make_grid(cellsize = 2000, square = F) %>%
  st_as_sf() %>%
  mutate(ID = row_number()) %>%
  rename(geom = x)
Zonas <- left_join(Zonas,
                   tibble(ID = rep(c(1:nrow(Zonas)), each = 29),
                          Periodo = rep(Per$Periodo, times = nrow(Zonas)), 
                          Día = rep(Per$tipodia, times = nrow(Zonas))
                          )
                   )
########################
dicc_metro <- read_delim(file = nodos, 
                         delim = ";",
                         locale = locale(encoding = "latin1")
                         ) %>%
  select(SIMT, CODTB9, X, Y) %>%
  filter(str_detect(SIMT, "^L")) %>%
  select(-SIMT, `Código paradero TS` = CODTB9, x = X, y = Y)
########################
geo_stops <- read_xlsx(A4, sheet = 1) %>%
  select("Código paradero TS", "x", "y") %>%
  bind_rows(dicc_metro) %>%
  distinct() %>%
  na.omit() %>%
  st_as_sf(coords = c("x", "y")) %>%
  st_set_crs(32719)
########################
rm(dicc_metro)
