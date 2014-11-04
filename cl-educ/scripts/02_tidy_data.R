#### Packages ####
rm(list=ls())
library(plyr)
library(dplyr)
# library(reshape2)
# library(ggplot2)
library(lubridate)
library(rCharts)


#### load RData ####
load("data/d_psu.RData")
load("data/d_sim.RData")
# load("../data/d_ren.RData")

d_psu %>% group_by(agno) %>% summarise(n())
d_sim %>% group_by(agno) %>% summarise(n())

vars <- setdiff(intersect(names(d_psu), names(d_sim)), c("agno", "rbd"))

d_psu_res <- d_psu[,setdiff(names(d_psu), vars)]
d_sim_res <- d_sim[,setdiff(names(d_sim), vars)]


colegios <- rbind.fill(d_psu[, c("rbd", vars)], d_sim[, c("rbd", vars)]) %>%
  distinct() %>%
  mutate(rbd = as.numeric(rbd))

d <- plyr::join(d_psu_res, d_sim_res, by = c("rbd", "agno"), type = "full") %>%
  arrange(rbd)

d <- as.matrix(sapply(d, as.numeric)) %>% as.data.frame()

d <- d %>% mutate(fecha = ymd(paste0(agno, "0101")))

rm(d_psu, d_psu_res, d_sim, d_sim_res)

head(d)
str(d)

save(d, colegios, file = "data/d_app.RData")

#### Testing alpha ####
head(d)
input <- list(rbd = 10088, var = "simce_mate")

# Data
d1 <- d %>%
  select(rbd, agno, value = get(input$var)) %>%
  group_by(agno) %>%
  summarize(n = n(),
            n.val = sum(!is.na(value)),
            p25 = quantile(value, .25, na.rm = TRUE),
            p50 = quantile(value, .50, na.rm = TRUE),
            p75 = quantile(value, .75, na.rm = TRUE))

d2 <- d %>%
  filter(rbd==input$rbd) %>%
  select(agno, value = get(input$var))

d3 <- join(d1, d2, by ="agno")

d3

# Plot
p <- Highcharts$new()

p$series(name = input$var, data = d3$value, type ="line", lineWidth = 9, color="#F0F0F0")
p$series(name = "med", data = d3$p50, type ="line", lineWidth = 1, dashStyle="dash", color="#000")
p$series(name = "p25", data = d3$p25, type ="line", lineWidth = 1, dashStyle="dot", color="#000")
p$series(name = "p75", data = d3$p75, type ="line", lineWidth = 1, dashStyle="dot", color="#000")

p$xAxis(categories = d3$agno)

p$plotOptions(line = list(marker = list(enabled = FALSE)))

# p$yAxis(min = 0)

p



# d_cast <- dcast(d, rbd ~ agno,  value.var= input$var)
# d_cast_rbd <- d_cast %>% filter(rbd == input$rbd)
# colegio_rbd <- colegios %>% filter(rbd == input$rbd)
# head(d_cast)



