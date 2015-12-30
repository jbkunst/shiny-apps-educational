proc_sols <- function(verbose = TRUE) {
  
  t0 <- Sys.time()
  
  library("RODBC")
  library("plyr")
  library("dplyr")
  library("stringr")
  
  options(stringsAsFactors = FALSE)
  
  chn <- odbcConnect("riesgo")
  # chn2 <- odbcConnect("riesgo2")
  
  qs <- readLines("~/TeamScoring/Programmability/SW_FactSolic_Excepciones_CC_v5.sql", warn = FALSE)
  
  qs <- paste(qs, collapse = "\n")
  
  qs <- str_split(qs, "-- q\\d+")
  
  qs <- str_trim(unlist(qs))
  
  
  l_ply(qs, function(q){
    if (verbose) {
      message(substr(q, 0, 200))
    }
    sqlQuery(chn, q)  
  }, .progress = "text")
  
  data <- sqlFetch(chn, "sw_sols_res")
  data <- riskr::pretty_df(data)
  
  save(data, file = "data/sw_sols_res.RData")
  
  print(Sys.time() - t0)

  message("ready")

    TRUE
  
}

# proc_sols()


load("data/sw_sols_res.RData")
str(data)

data <- data %>% select(camada, rut_num, desc_path_sw, segmento_label)
data <- data %>% filter(!desc_path_sw %in% c("", "Moroso", "Renegociado"))
data <- data %>%
  mutate(seg = ifelse(segmento_label == "Personal Banking", "PB", "CF"),
         periodo = paste0(camada, "01") %>% ymd())

save(data, file = "data/sw_sols_res_min.RData")

