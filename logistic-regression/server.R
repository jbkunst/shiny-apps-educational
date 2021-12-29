# input <- list(
#   n = 500,
#   relationship = "x > y",
#   percent_noise = 10,
#   order = 8
# )

shinyServer(function(input, output) {
  
  data <- reactive({

    set.seed(1234)
    
    data <- tibble(
      x = runif(input$n, -1, 1),
      y = runif(input$n, -1, 1)
    )
    
    data <- data %>%
      mutate(
        response := eval(parse(text = input$relationship))
        # response = sin(x*pi) > sin(y*pi)  
        )

    data <- data %>%
      mutate(
        response = ifelse(runif(input$n) < input$percent_noise/100, !response, response)
        )

    # glimpse(data)
    
    data

  })

  mod <- reactive({

    data <- data()

    mod <- suppressWarnings(
      glm(response ~
            poly(x, input$order, raw = TRUE, simple = TRUE) +
            poly(y, input$order, raw = TRUE, simple = TRUE),
          family = binomial,
          data = data
          )
      )

    mod

  })

  dgrd <- reactive({

    mod <- mod()

    dgrd  <- crossing(
      x = seq(-1, 1, by = 0.05),
      y = seq(-1, 1, by = 0.05)
      ) %>%
      mutate(
        pred = predict(mod, newdata = ., type = "response")
        )

    dgrd

  })
  
  output$predfield <- renderPlot({

    data <- data()
    dgrd <- dgrd()

    ggplot() +

      # predictions
      geom_contour_fill(aes(x, y, z = pred), data = dgrd, bins = 100) +
      scale_fill_divergent(name = expression("P(·|x,y)"), midpoint = 0.5,
                           breaks = seq(0, 1, by = 0.25),
                           limits = c(0, 1)
                           ) +
      geom_text_contour(aes(x, y, z = pred), data = dgrd, stroke = 0.2) +

      # data
      geom_point(aes(x, y, color = factor(response), shape = factor(response)),
                 data = data, size = 2) +
      scale_shape_manual(name = NULL, values = c(1, 4)) +
      scale_color_manual(name = NULL, values = c(muted("blue"), muted("red"))) +

      # theme
      # theme_void()
      theme(legend.key.width = unit(2,"cm"))

  })
  
  output$marginals <- renderPlot({
    
    data <- data()

    data %>%
      gather(key, value, -response) %>%
      mutate(key = str_glue("variable {key}")) %>% 
      ggplot(aes(value, as.numeric(response))) +
      geom_point(
        aes(color = factor(response), shape = factor(response)), size = 2,
        position = position_jitter(height = 0.075)) +
      scale_shape_manual(name = NULL, values = c(1, 4)) +
      scale_color_manual(name = NULL, values = c(muted("blue"), muted("red"))) +
      
      scale_y_continuous(
        breaks = c(0, 1),
        labels = c("FALSE (response = 0)", "TRUE (response = 1)")
        ) +
      
      geom_smooth(
        color = primary_color, size = 1.2, alpha = 0.1, 
        method = "loess", formula  = y ~ x
        ) +
      
      labs(
        x = NULL,
        y = NULL
      ) +
      
      facet_wrap(vars(key))
    
  })
  
  output$roccurve <- renderPlot({
    
    mod <- mod()
    
    aucroc <- Metrics::auc(
      actual = as.numeric(mod$data$response),
      predicted = mod$fitted.values
      )
    
    risk3r::gg_model_roc(mod, size = 2, color = primary_color) +
      labs(
        title = str_glue("AUC: { percent(aucroc)  }")
      ) +
      theme(legend.position = "none")
    
  })
  
  output$densities <- renderPlot({
    
    mod <- mod()
    
    dprd <- mod$data %>% 
      mutate(pred = predict(mod, newdata = ., type = "response"))
    
    ggplot(dprd, aes(pred, group = response, fill = response, color = response, label = response)) +
      geom_density(alpha = 0.1, size = 2) +
      geom_textdensity(size = 4, fontface = 1, hjust = 0.2, vjust = -0.5) +
      scale_y_continuous(labels = NULL) +
      labs(x = "Probability") +
      theme(legend.position = "none")
    
  })
  
  output$model <- renderTable({
    
    mod <- mod()
    
    dmod <- tidy(mod) %>% 
      mutate(
        term =  str_c(
          str_extract(term, "poly\\([x|y]") %>% str_remove("poly\\("),
          "^",
          str_extract(term, "[0-9]{0,1}$")
        ),
        term = coalesce(term, "(Intercept)"),
        term = str_remove(term, "\\^$"),
        # term = str_glue("\\( {term} \\)"),
        
        ` ` = symnum(p.value, corr = FALSE, na = FALSE, legend = FALSE,
                     cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                     symbols = c("***", "**", "*", ".", " "))
        
      )
    
    dmod
    
  })
  
  
})
