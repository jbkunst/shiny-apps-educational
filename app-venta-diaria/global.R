# rm(list = ls())
library("shiny")
library("shinydashboard")
library("DT")
library("riskr")
library("ggplot2")
library("scales")
library("lubridate")
library("ggthemes")
library("dplyr")
library("riskr")
library("lubridate")
library("tidyr")
library("plotly")
library("RODBC")

options(stringsAsFactors = FALSE)
chn <- odbcConnect("riesgo")

options(DT.options = list(searching = FALSE, paging = FALSE, ordering = FALSE))

theme_set(theme_minimal(base_size = 11) + 
            theme(legend.position = "bottom"))

update_geom_defaults("line", list(colour = "#dd4b39", size = 1.05))
update_geom_defaults("point", list(colour = "#434348", size = 1.2))
update_geom_defaults("bar", list(fill = "#7cb5ec"))
update_geom_defaults("text", list(size = 4, colour = "gray30"))


maxper <- sqlQuery(chn, "select max(camada) from rt_scoring.dbo.sw_sols_res")[[1]]
query <- 
"select camada, segmento_label, desc_path_sw, ri, resultado_sw, count(*) as count
from rt_scoring.dbo.sw_sols_res
where
camada >= 201301 and camada < %s
and desc_path_sw in ('Antiguo', 'Antiguo Campana', 'Nuevo', 'Nuevo Campana')
and ri in ('A','B','C','D','E')
group by camada, segmento_label, desc_path_sw, ri, resultado_sw" %>% 
  sprintf(maxper)
dfressol <- sqlQuery(chn, query) %>% 
  tbl_df() %>%
  mutate(periodo = paste0(camada, "01") %>% ymd() + days(1)) %>% 
  rename(risk_indicator = ri)
save(dfressol, file = "data/dfressol.RData")  



maxper2 <- paste0(maxper, "01") %>% ymd() %>% {. - months(12)} %>% format("%Y%m")
query <- 
"
select 
camada, segmento_label,
desc_path_sw, ri, scoresinacoficliente as score_sinacofi,
score_cf_ori_calculado, score_pb_ori_calculado, score_bhv,
score_interno = case
	when segmento_label = 'Consumer Finance' and (desc_path_sw in ('Nuevo', 'Nuevo Campana')) then score_cf_ori_calculado
  when segmento_label = 'Personal Banking' and (desc_path_sw in ('Nuevo', 'Nuevo Campana')) then score_pb_ori_calculado
  when desc_path_sw in ('Antiguo', 'Antiguo Campana') then score_bhv
end,
bg = case when castigos_2 is null then 1 else 0 end
from rt_scoring.dbo.sw_sols_res
where
camada >= 201301 and camada < %s
and resultado_sw = 'Aceptado'
and desc_path_sw in ('Antiguo', 'Antiguo Campana', 'Nuevo', 'Nuevo Campana')
and ri in ('A','B','C','D','E')
" %>% 
  sprintf(maxper)
dfperf <- sqlQuery(chn, query) %>% 
  tbl_df() %>%
  mutate(periodo = paste0(camada, "01") %>% ymd() + days(2)) %>% 
  filter(!is.na(score_interno))

save(dfperf, file = "data/dfperf.RData")  

segmento_choices <- c("Personal Banking" ,"Consumer Finance")
path_choices <- c("Antiguo", "Antiguo Campana", "Nuevo", "Nuevo Campana")
slider_choices <- sort(unique(dfressol$camada))

# source("scripts/queries.R")
