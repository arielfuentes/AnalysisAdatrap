#libraries
library(dplyr)
library(dtplyr)
library(data.table)
library(sf)

#DF to report travels and trips 
viajes <- vjs_submd %>%
  group_by(Día, 
           Periodo, 
           submodo_1era) %>%
  summarise(Viajes = sum(Demanda)) %>%
  rename(Submodo = submodo_1era) %>%
  ungroup()

etapas <- as_tibble(select(filter(vjs_submd, 
                                  submodo_1era != "-"), 
                           Día, 
                           Periodo, 
                           Submodo = submodo_1era, 
                           Demanda
                           )
                    ) %>%
  bind_rows(as_tibble(select(filter(vjs_submd, 
                                    submodo_2da != "-"), 
                             Día, 
                             Periodo, 
                             Submodo = submodo_2da, 
                             Demanda
                             )
                      )
            )  %>%
  bind_rows(as_tibble(select(filter(vjs_submd, 
                                    submodo_3era != "-"), 
                             Día, 
                             Periodo, 
                             Submodo = submodo_3era, 
                             Demanda
                             )
                      )
            ) %>%
  bind_rows(as_tibble(select(filter(vjs_submd, 
                                    submodo_4ta != "-"), 
                             Día, 
                             Periodo, 
                             Submodo = submodo_4ta, 
                             Demanda
                             )
                      )
            ) %>%
  lazy_dt() %>%
  group_by(Día, Periodo, Submodo) %>%
  summarise(Etapas = sum(Demanda)) %>%
  ungroup()

rm(vjs_submd)

tb2_tbl <- left_join(viajes, etapas) %>%
  mutate(Transbordos = Etapas/Viajes) %>%
  left_join(class_día) %>%
  arrange(NDía) %>%
  select(-NDía)
####################################
#work with spatial data
Sube <- select(SubeBaja, Periodo, Día, paraderosubida, Demanda) %>%
  group_by(Periodo, Día, paraderosubida) %>%
  summarise(DdaSub = sum(Demanda)) %>%
  ungroup() 

Baja <- select(SubeBaja, Periodo, Día, paraderobajada, Demanda) %>%
  group_by(Periodo, Día, paraderobajada) %>%
  summarise(DdaBaj = sum(Demanda)) %>%
  ungroup() 

rm(SubeBaja)

sp_jn <- st_join(x = Zonas, y = geo_stops, join = st_contains) %>%
  rename(paraderosubida = `Código paradero TS`) %>%
  left_join(Sube, copy = T) %>%
  rename(paraderobajada = paraderosubida) %>%
  left_join(Baja, copy = T) %>%
  mutate_at(vars(matches("Dda")), replace_na, 0) %>%
  rename(paradero = paraderobajada) %>%
  group_by(ID, Periodo, Día) %>%
  summarise(DdaSub = sum(DdaSub), DdaBaj = sum(DdaBaj)) %>%
  ungroup() %>%
  left_join(class_día) %>%
  arrange(NDía, Periodo) %>%
  filter(DdaSub > 0)
