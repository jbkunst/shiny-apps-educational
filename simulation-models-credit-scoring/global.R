rm(list = ls())
library("shiny")
library("shinythemes")
library("dplyr")
library("highcharter")
library("riskr")
library("formattable")

options(shiny.launch.browser = TRUE)

rbeta2 <- function(n, mu = 1,  var = 0.1, seed = 1) {
  # mu <- 1;  var <- 1
  estBetaParams <- function(mu, var) {
    alpha <- ((1 - mu) / var - 1 / mu) * mu ^ 2
    beta <- alpha * (1 / mu - 1)
    return(params = list(alpha = alpha, beta = beta))
  }
  pars <- estBetaParams(mu, var)
  set.seed(10)
  rbeta(n, pars$alpha, pars$beta)
}

prob_to_score <- function(x){
  round(1000 * x)
} 

ggdist <- function(label, score, cutoff) {
  
  co <- as.numeric(quantile(score, cutoff))
  
  data_frame(label, score) %>% 
    ggplot() + 
    geom_density(aes(score, fill = factor(label)), alpha = 0.55) + 
    scale_fill_manual(values = c("darkred", "darkblue")) +
    geom_vline(aes(xintercept = co), color = "gray") + 
    ylab(NULL) + xlab(NULL) +
    xlim(0, 1000) + 
    theme_minimal() + 
    theme(legend.position = "none",
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank())
}

hcdist <- function(label = df$label, score = df$score2, cutoff = 0.2) {
  
  co <- as.numeric(quantile(score, cutoff))
  
  highchart() %>% 
    hc_chart(type = "area") %>% 
    hc_plotOptions(series = list(fillOpacity = 0.5, showInLegend = FALSE)) %>% 
    hc_add_series(score[label == 0] %>% density(), color = hex_to_rgba("red", 1), name = "Malos") %>% 
    hc_add_series(score[label == 1] %>% density(), color = hex_to_rgba("blue", 1), name = "Buenos") %>% 
    hc_xAxis(min = 0, max = 1000, plotLines = list(list(value = co, width = 2, color = "gray"))) %>% 
    hc_yAxis(visible = FALSE) %>% 
    hc_tooltip(enabled = FALSE)
}

mnttbl <- function(label, score, cutoff, mnt) {
  co <- as.numeric(quantile(score, cutoff))
  data_frame(label, score) %>% 
    mutate(comportamiento = ifelse(label, "Bueno", "Malo"),
           desicion = ifelse(score <= co, "Rechazado", "Aceptado")) %>% 
    group_by(comportamiento, desicion) %>% 
    summarise(solicitudes = n()) %>% 
    ungroup() %>% 
    mutate(solicitudes = accounting(solicitudes, digits = 0),
           monto = 1/ 1e6 * solicitudes * mnt,
           monto = currency(monto, "$", digits = 0),
           pmonto  = monto/sum(monto),
           pmonto = percent(pmonto),
           estrategia = ifelse((comportamiento == "Bueno" &  desicion == "Aceptado") |
                                 (comportamiento == "Malo" &  desicion == "Rechazado"), TRUE, FALSE)) 
} 

fmttb <- function(dfbench) {
  formattable(dfbench)
}
