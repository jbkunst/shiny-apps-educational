#### Packages ####
rm(list=ls())
library(plyr)
library(dplyr)
# library(reshape2)
# library(ggplot2)
library(lubridate)


#### load RData ####
load("data/xlsx_data.RData")
# load("data/d_psu.RData")
# load("data/d_sim.RData")
# load("data/d_ren.RData")

d_psu %>% group_by(agno) %>% summarise(n())
d_sim %>% group_by(agno) %>% summarise(n())

vars <- setdiff(intersect(names(d_psu), names(d_sim)), c("agno", "rbd"))

d_psu_res <- d_psu[,setdiff(names(d_psu), vars)]
d_sim_res <- d_sim[,setdiff(names(d_sim), vars)]


anios <- rbind.fill(d_psu[, c("rbd", "agno")], d_sim[, c("rbd", "agno")]) %>%
  distinct() %>%
  group_by(rbd) %>%
  summarise(max_agno = max(agno))

colegios <- rbind.fill(d_psu[, c("rbd", vars)], d_sim[, c("rbd", vars)]) %>%
  distinct() %>%
  mutate(rbd = as.numeric(rbd))

colegios <- plyr::join(colegios, anios, by = "rbd")
head(colegios)


d <- plyr::join(d_psu_res, d_sim_res, by = c("rbd", "agno"), type = "full") %>%
  arrange(rbd)

d <- as.matrix(sapply(d, as.numeric)) %>% as.data.frame()

d <- d %>% mutate(fecha = ymd(paste0(agno, "0101")))

rm(d_psu, d_psu_res, d_sim, d_sim_res, vars)

head(d)
str(d)

save(d, colegios, file = "data/consolidate_data.RData")
