library("taucharts")


line_dat <- structure(list(type = c("us", "us", "us", "us", "us", "us", "bug", 
                                    "bug", "bug", "bug", "bug"), count = c(0L, 10L, 15L, 12L, 16L, 
                                                                           13L, 21L, 19L, 23L, 26L, 23L), date = c("12-2013", "01-2014", 
                                                                                                                   "02-2014", "03-2014", "04-2014", "05-2014", "01-2014", "02-2014", 
                                                                                                                   "03-2014", "04-2014", "05-2014")), .Names = c("type", "count", 
                                                                                                                                                                 "date"), class = "data.frame", row.names = c(NA, 11L))


head(line_dat)
tauchart(line_dat) %>% 
  tau_line("date", "count", "type") %>% 
  tau_guide_x(label="Month") %>% 
  tau_guide_y(label="Count of completed entities", label_padding=50) %>% 
  tau_guide_padding(70, 70, 10, 10)

head(df_aux)
tauchart(df_aux) %>% 
  tau_line("periodo", "count", c("segmento_label", "desc_path_sw")) 
  
