#### Packages ####
rm(list=ls())
library(plyr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(lubridate)


#### load RData ####
load("../data/d_psu.RData")
load("../data/d_sim.RData")
# load("../data/d_ren.RData")

d_psu %>% group_by(agno) %>% summarise(n())
d_sim %>% group_by(agno) %>% summarise(n())


vars <- setdiff(intersect(names(d_psu), names(d_sim)), c("agno", "rbd"))

d_psu_res <- d_psu[,setdiff(names(d_psu), vars)]
d_sim_res <- d_sim[,setdiff(names(d_sim), vars)]


colegios <- rbind.fill(d_psu[, c("rbd", vars)], d_sim[, c("rbd", vars)]) %>%
  unique() %>%
  mutate(rbd = as.numeric(rbd))


head(d_psu_res)
head(d_sim_res)
head(colegios)

d <- plyr::join(d_psu_res, d_sim_res, by = c("rbd", "agno"), type = "full") %>%
  arrange(rbd)

d <- as.matrix(sapply(d, as.numeric)) %>% as.data.frame()

d <- d %>% mutate(fecha = ymd(paste0(agno, "0101")))
  

rm(d_psu, d_psu_res, d_sim, d_sim_res)

head(d)




#### Testing alpha ####
input <- list(rbd = 1000, var = "psu_nem")


colMedians

d_cast <- dcast(d, rbd ~ agno,  value.var= input$var)

d_cast_rbd <- d_cast %>% filter(rbd == input$rbd)
colegio_rbd <- colegios %>% filter(rbd == input$rbd)


head(d_cast)


  

