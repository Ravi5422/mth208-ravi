library(shiny)
library(ggplot2)
library(dplyr)
library(shinythemes)
library(readr)
library(shinyWidgets)


cancer_data <- read_csv("Types of Cancer Deaths.csv")

state_data <- read.csv("heat map pf states.csv", stringsAsFactors = FALSE) %>%
  filter(Measure == "Percent of total deaths") %>%
  mutate(Value = Value * 100)


self_harm <- read.csv("self harm.csv", stringsAsFactors = FALSE)
self_harm$year <- as.numeric(self_harm$year)


cancer_pred <- read_csv("Cancer Prediction India rate.csv") %>%
  filter(Scenario == "Reference", Sex == "Both", Age == "All ages", `Cause of death or injury` == "Neoplasms") %>%
  select(Year, Value) %>%
  rename(year = Year, mortality_rate = Value) %>%
  arrange(year)


ui <- navbarPage(
  title = "India Health Dashboard",
  theme = shinytheme("slate"),
  
  # ── Tab 1: State Cause Percentages ──
  tabPanel(
    "State Cause Percentages (2021)",
    fluidPage(
      sidebarLayout(
        sidebarPanel(
          h4("Select a State or UT", style = "color: #e0e0e0;"),
          pickerInput(
            "location",
            NULL,
            choices = sort(unique(state_data$Location)),
            selected = "Andhra Pradesh",
            options = list(`live-search` = TRUE, `actions-box` = TRUE),
            width = "100%",
            choicesOpt = list(style = "background-color: #384047; color: white;")
          )
        ),
        mainPanel(
          h3(
            "Percent of Total Deaths (15–49 years, Both Sexes, 2021)",
            style = "color: #f8f9fa; margin-bottom: 20px;"
          ),
          uiOutput("death_tiles")
        )
      )
    )
  ),
  
  
  tabPanel(
    "Cancer",
    fluidPage(
      tabsetPanel(
        tabPanel(
          "Historical Trends (2017–2021)",
          sidebarLayout(
            sidebarPanel(
              h4("Select Cancer Type(s):", style = "color: #e0e0e0;"),
              checkboxGroupInput(
                "cancers",
                NULL,
                choices = sort(unique(cancer_data$cause_name)),
                selected = "Breast cancer"
              )
            ),
            mainPanel(
              plotOutput("deathPlot", height = "600px")
            )
          )
        ),
        
        tabPanel(
          "Mortality Forecast & Analysis",
          h3("Cancer Mortality Trends and Forecast (India)",
             style = "color: #f8f9fa; text-align: center; margin-bottom: 25px;"),
          
          fluidRow(
            column(
              6,
              div(
                style = "
                  background: #2c2f33;
                  color: white;
                  padding: 20px;
                  border-radius: 12px;
                  text-align: center;
                  box-shadow: 0 4px 10px rgba(0,0,0,0.4);
                  border-left: 5px solid #c49cde;
                ",
                h4("Predicted Cancer Mortality Rate in 2025", style = "margin-bottom: 15px; color: #e0e0e0;"),
                h2(textOutput("pred_2025"), style = "color: #c49cde; font-weight: bold; margin: 0;")
              )
            ),
            column(
              6,
              div(
                style = "background: #2c2f33; padding: 20px; border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.4);",
                h4("Average Annual Change in Mortality Rate", style = "color: #e0e0e0; margin-top: 0;"),
                fluidRow(
                  column(6, selectInput("start_year", "Start Year:", choices = cancer_pred$year, selected = 2010)),
                  column(6, selectInput("end_year", "End Year:", choices = cancer_pred$year, selected = 2025))
                ),
                br(),
                h3(textOutput("avg_change"), style = "color: #51cf66; font-weight: bold; text-align: center;")
              )
            )
          ),
          br(),
          plotOutput("cancer_trend_plot", height = "400px")
        )
      )
    )
  ),
  
  tabPanel(
    "Self-Harm Deaths (2012–2021)",
    fluidPage(
      tags$head(tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css")),
      
      tags$h1("Self-Harm Deaths in India (2012–2021)",
              style = "color: white; text-align: center; margin-bottom: 20px; font-family: 'Segoe UI', sans-serif; font-weight: 500;"),
      
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "selected_year",
            "Select Year:",
            choices = sort(unique(self_harm$year)),
            selected = 2021
          )
        ),
        
        mainPanel(
          div(
            style = "margin-bottom: 25px;",
            fluidRow(
              column(4,
                     div(class = "card card-male",
                         div(class = "card-content",
                             div(class = "card-number", textOutput("male_deaths")),
                             div(class = "card-label", "Male Deaths")
                         ),
                         div(class = "icon", icon("male"))
                     )
              ),
              column(4,
                     div(class = "card card-female",
                         div(class = "card-content",
                             div(class = "card-number", textOutput("female_deaths")),
                             div(class = "card-label", "Female Deaths")
                         ),
                         div(class = "icon", icon("female"))
                     )
              ),
              column(4,
                     div(class = "card card-ratio",
                         div(class = "card-content",
                             div(class = "card-number", textOutput("ratio")),
                             div(class = "card-label", "Male to Female Ratio")
                         ),
                         div(class = "icon", icon("balance-scale"))
                     )
              )
            )
          ),
          
          plotOutput("trend_plot", height = "500px")
        )
      ),
      
      tags$style(HTML("
        .card {
          border-radius: 12px;
          padding: 16px;
          margin: 10px 0;
          background: rgba(255,255,255,0.08);
          display: flex;
          flex-direction: row;
          align-items: center;
          justify-content: space-between;
          color: white;
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          box-shadow: 0 4px 8px rgba(0,0,0,0.3);
          transition: transform 0.2s ease;
          overflow: hidden;
          min-height: 80px;
        }
        .card:hover {
          transform: translateY(-2px);
          background: rgba(255,255,255,0.12);
        }
        .card-content {
          flex: 1;
          text-align: left;
          overflow: hidden;
        }
        .card-number {
          font-size: 28px;
          font-weight: bold;
          margin: 0;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .card-label {
          font-size: 13px;
          opacity: 0.9;
          margin-top: 4px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
        .icon {
          font-size: 28px;
          opacity: 0.7;
          margin-left: 12px;
          flex-shrink: 0;
        }
        .card-male { background-color: #4E79A7; }
        .card-female { background-color: #F28E2B; }
        .card-ratio { background-color: #E15759; }

        @media (max-width: 768px) {
          .card {
            flex-direction: column;
            text-align: center;
            padding: 14px;
            min-height: auto;
          }
          .card-content {
            margin-bottom: 8px;
          }
          .icon {
            margin: 6px 0 0 0;
          }
        }
      "))
    )
  ),
  
  tabPanel(
    "About",
    fluidPage(
      h2("About This Dashboard", style = "color: #f8f9fa; margin-bottom: 20px;"),
      tags$div(
        style = "background-color: #2c2f33; padding: 20px; border-radius: 10px; margin-bottom: 25px;",
        p(
          "This dashboard visualizes key health trends in India using data from the ",
          tags$a(href = "https://vizhub.healthdata.org/gbd-compare/", "Global Burden of Disease (GBD) Study 2021", target = "_blank"),
          " by the Institute for Health Metrics and Evaluation (IHME).",
          style = "color: #e0e0e0; font-size: 16px;"
        )
      ),
      
      h3("Data Sources", style = "color: #c49cde; margin-top: 30px;"),
      tags$div(
        style = "background-color: #272b30; padding: 15px; margin-bottom: 15px; border-left: 4px solid #51cf66; border-radius: 6px;",
        h4("State-Level Cause of Death (2021)", style = "color: #51cf66; margin-top: 0;"),
        p(
          "Source: ",
          tags$code("heat map pf states.csv"),
          br(),
          "Contains cause-specific mortality percentages for ages 15–49 in all Indian states and union territories for 2021.",
          br(),
          "Includes causes like cardiovascular diseases, neoplasms, respiratory infections, digestive diseases, and more.",
          style = "color: #d0d0d0; margin-bottom: 0;"
        )
      ),
      
      tags$div(
        style = "background-color: #272b30; padding: 15px; margin-bottom: 15px; border-left: 4px solid #c49cde; border-radius: 6px;",
        h4("Cancer Mortality by Type (2017–2021)", style = "color: #c49cde; margin-top: 0;"),
        p(
          "Source: ",
          tags$code("Types of Cancer Deaths.csv"),
          br(),
          "Provides annual death counts for major cancer types in India (e.g., breast, prostate, liver, oral cavity).",
          br(),
          "Used to show historical trends in cancer-specific mortality.",
          style = "color: #d0d0d0; margin-bottom: 0;"
        )
      ),
      
      tags$div(
        style = "background-color: #272b30; padding: 15px; margin-bottom: 15px; border-left: 4px solid #ff6b6b; border-radius: 6px;",
        h4("Self-Harm Deaths (2012–2021)", style = "color: #ff6b6b; margin-top: 0;"),
        p(
          "Sources: ",
          tags$code("self harm.csv"), " and ", tags$code("Deaths Self Harm.csv"),
          br(),
          "Contains yearly counts of self-harm deaths in India by sex (2012–2021).",
          br(),
          "Enables analysis of gender disparities and temporal trends in suicide mortality.",
          style = "color: #d0d0d0; margin-bottom: 0;"
        )
      ),
      
      tags$div(
        style = "background-color: #272b30; padding: 15px; margin-bottom: 15px; border-left: 4px solid #adb5bd; border-radius: 6px;",
        h4("Cancer Mortality Forecast (1990–2050)", style = "color: #adb5bd; margin-top: 0;"),
        p(
          "Source: ",
          tags$code("Cancer Prediction India rate.csv"),
          br(),
          "Projected age-standardized cancer mortality rates (deaths per 100,000) under the 'Reference' scenario.",
          br(),
          "Used for forecasting and trend analysis up to 2050.",
          style = "color: #d0d0d0; margin-bottom: 0;"
        )
      ),
      
      hr(style = "border-color: #444;"),
      
      p(
        tags$strong("Data Attribution:"),
        br(),
        "Institute for Health Metrics and Evaluation (IHME). GBD Compare and GBD Foresight Data Visualizations. Global Burden of Disease Study 2021 & 2019. Seattle, WA: IHME, University of Washington, 2023 & 2020.",
        br(),
        "Available from ",
        tags$a(href = "https://vizhub.healthdata.org/gbd-compare/", "GBD Compare", target = "_blank"),
        " and ",
        tags$a(href = "https://vizhub.healthdata.org/gbd-foresight/", "GBD Foresight", target = "_blank"),
        ".",
        style = "color: #aaa; font-size: 14px; margin-top: 20px;"
      )
    )
  )
)


server <- function(input, output, session) {
  
  output$death_tiles <- renderUI({
    req(input$location)
    
    causes_of_interest <- c(
      "Cardiovascular diseases",
      "Respiratory infections and tuberculosis",
      "Neoplasms",
      "Nutritional deficiencies",
      "Digestive diseases",
      "Diabetes and kidney diseases"
    )
    
    df <- state_data %>%
      filter(
        Location == input$location,
        Cause.of.death.or.injury %in% causes_of_interest
      ) %>%
      select(Cause.of.death.or.injury, Value)
    
    if (nrow(df) == 0) {
      return(h4("No data available.", style = "color: #ff6b6b; text-align: center;"))
    }
    
    display_order <- c(
      "Cardiovascular diseases",
      "Neoplasms",
      "Respiratory infections and tuberculosis",
      "Nutritional deficiencies",
      "Digestive diseases",
      "Diabetes and kidney diseases"
    )
    
    df <- df %>%
      mutate(
        Cause.of.death.or.injury = factor(Cause.of.death.or.injury, levels = display_order)
      ) %>%
      arrange(Cause.of.death.or.injury) %>%
      mutate(Cause.of.death.or.injury = as.character(Cause.of.death.or.injury))
    
    color_map <- c(
      "Cardiovascular diseases"           = "#ff6b6b",
      "Neoplasms"                         = "#c49cde",
      "Respiratory infections and tuberculosis" = "#51cf66",
      "Nutritional deficiencies"          = "#ffd43b",
      "Digestive diseases"                = "#3bc9db",
      "Diabetes and kidney diseases"      = "#adb5bd"
    )
    
    tile_list <- lapply(seq_len(nrow(df)), function(i) {
      cause <- df$Cause.of.death.or.injury[i]
      pct   <- round(df$Value[i], 1)
      color <- color_map[cause]
      
      div(
        class = "cause-tile",
        style = paste0(
          "background: #2c2f33; ",
          "color: white; ",
          "padding: 20px; ",
          "margin: 10px; ",
          "border-radius: 12px; ",
          "box-shadow: 0 4px 10px rgba(0, 0, 0, 0.4); ",
          "border-left: 5px solid ", color, "; ",
          "text-align: center; ",
          "transition: transform 0.2s ease-in-out; "
        ),
        onRender = "this.style.transform = 'scale(1)'; this.addEventListener('mouseenter', () => this.style.transform = 'scale(1.03)'); this.addEventListener('mouseleave', () => this.style.transform = 'scale(1)');",
        div(
          style = "font-size: 18px; font-weight: 600; margin-bottom: 12px; color: #f0f0f0;",
          cause
        ),
        div(
          style = paste0("font-size: 32px; font-weight: bold; color: ", color, ";"),
          paste0(pct, "%")
        )
      )
    })
    
    div(
      style = "
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 20px;
        padding: 10px;
      ",
      tile_list
    )
  })
  
  filtered_cancer_data <- reactive({
    req(input$cancers)
    if (length(input$cancers) == 0) return(cancer_data[0, ])
    
    cancer_data %>%
      filter(cause_name %in% input$cancers) %>%
      arrange(year)
  })
  
  output$deathPlot <- renderPlot({
    data <- filtered_cancer_data()
    
    if (nrow(data) == 0) {
      plot.new()
      text(
        0.5, 0.5,
        "Select at least one cancer type",
        cex = 1.8,
        col = "white",
        font = 2
      )
      return()
    }
    
    ggplot(data, aes(x = year, y = val, color = cause_name, group = cause_name)) +
      geom_line(linewidth = 1.3) +
      geom_point(size = 2.5, stroke = 0.5) +
      labs(
        title = "Cancer Deaths in India Over Time (2017–2021)",
        x = "Year",
        y = "Number of Deaths",
        color = "Cancer Type"
      ) +
      scale_x_continuous(breaks = sort(unique(data$year))) +
      scale_color_brewer(type = "qual", palette = "Set2") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, color = "white", size = 18, face = "bold"),
        axis.text = element_text(color = "white", size = 11),
        axis.title = element_text(color = "white", size = 12, face = "bold"),
        legend.text = element_text(color = "white", size = 11),
        legend.title = element_text(color = "white", size = 12, face = "bold"),
        panel.background = element_rect(fill = "#1e1e1e"),
        plot.background = element_rect(fill = "#1a1a1a"),
        legend.background = element_rect(fill = "#2c2c2c", color = "#444"),
        legend.key = element_rect(fill = "#333333"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#3a3a3a")
      )
  })
  
  selected_data <- reactive({
    self_harm %>% filter(year == input$selected_year)
  })
  
  output$male_deaths <- renderText({
    male_val <- selected_data() %>% filter(sex_name == "Male") %>% pull(val)
    if (length(male_val) == 0) return("—")
    format(round(male_val, 0), big.mark = ",")
  })
  
  output$female_deaths <- renderText({
    female_val <- selected_data() %>% filter(sex_name == "Female") %>% pull(val)
    if (length(female_val) == 0) return("—")
    format(round(female_val, 0), big.mark = ",")
  })
  
  output$ratio <- renderText({
    male_val <- selected_data() %>% filter(sex_name == "Male") %>% pull(val)
    female_val <- selected_data() %>% filter(sex_name == "Female") %>% pull(val)
    if (length(male_val) == 0 || length(female_val) == 0 || female_val == 0) return("—")
    ratio <- round(male_val / female_val, 1)
    paste0(ratio, ":1")
  })
  
  output$trend_plot <- renderPlot({
    plot_data <- self_harm %>%
      group_by(year, sex_name) %>%
      summarise(total = sum(val), .groups = "drop")
    
    ggplot(plot_data, aes(x = year, y = total, color = sex_name, group = sex_name)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 2) +
      scale_color_manual(values = c("Male" = "#4DAF4A", "Female" = "#FF7F00")) +
      labs(
        title = "Trend of Self-Harm Deaths in India (2012–2021)",
        x = "Year",
        y = "Number of Deaths",
        color = "Sex"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(color = "white", hjust = 0.5, size = 16),
        axis.title = element_text(color = "white"),
        axis.text = element_text(color = "white"),
        legend.title = element_text(color = "white"),
        legend.text = element_text(color = "white"),
        panel.background = element_rect(fill = "#272b30"),
        plot.background = element_rect(fill = "#272b30"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#384047")
      )
  })
  
  output$pred_2025 <- renderText({
    rate_2025 <- cancer_pred %>% filter(year == 2025) %>% pull(mortality_rate)
    if (length(rate_2025) == 0) return("—")
    paste0(round(rate_2025, 1), " per 100,000")
  })
  
  output$avg_change <- renderText({
    start <- as.numeric(input$start_year)
    end <- as.numeric(input$end_year)
    
    if (start >= end) {
      return("End year must be after start year")
    }
    
    df_range <- cancer_pred %>% filter(year >= start & year <= end)
    
    if (nrow(df_range) < 2) {
      return("Insufficient data")
    }
    
    model <- lm(mortality_rate ~ year, data = df_range)
    avg_change_val <- coef(model)["year"]
    
    direction <- ifelse(avg_change_val > 0, "↑", "↓")
    paste0(direction, " ", round(abs(avg_change_val), 2), " per 100,000 per year")
  })
  
  output$cancer_trend_plot <- renderPlot({
    ggplot(cancer_pred, aes(x = year, y = mortality_rate)) +
      geom_line(color = "#c49cde", linewidth = 1.2) +
      geom_point(color = "#c49cde", size = 2) +
      labs(
        title = "Cancer Mortality Rate in India (1990–2050)",
        y = "Deaths per 100,000",
        x = "Year"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(color = "white", hjust = 0.5, size = 14),
        axis.title = element_text(color = "white"),
        axis.text = element_text(color = "white"),
        panel.background = element_rect(fill = "#1e1e1e"),
        plot.background = element_rect(fill = "#1a1a1a"),
        panel.grid.major = element_line(color = "#3a3a3a"),
        panel.grid.minor = element_blank()
      )
  })
}



shinyApp(ui = ui, server = server)
