library(shiny)
library(reshape2)
library(ggplot2)
library(data.table)
library(readr)
library(shinythemes)
library(magrittr)

# Written by Hon Ching YEUNG
# Identifiant INE: 1310002052228
# Published shiny app web site: https://honchingyeung.shinyapps.io/Shiny_app/
# Github: https://github.com/honcyeung

# read the data
data <- read_csv(url("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"))
coronaD <- data.table(data)

# make a row for EU27 in coronaD
EU27 <- c("Austria", "Belgium", "Bulgaria", "Croatia", 
          "Cyprus", "Czech Republic", "Denmark", 
          "Estonia", "Finland", "France", "Germany", "Greece", 
          "Hungary", "Ireland", "Italy", "Latvia", "Lithuania", 
          "Luxembourg", "Malta", "Netherlands", "Poland", "Portugal", 
          "Romania", "Slovakia", "Slovenia", "Spain", "Sweden")
EU27DT <- coronaD[`Country/Region` %in% EU27][is.na(`Province/State`)] %>% `[` (,-(1:4)) %>% `colSums` %>% `t`
coronaD <- rbind(coronaD,cbind(data.table("Province/State" = NA_character_, "Country/Region" = "EU27", "Lat" = NA_character_, "Long" = NA_character_), EU27DT))

# change data type of date column to "Date"
dates <- colnames(coronaD[, -(1:4)])
PlotDT <- melt(coronaD, id.vars = 1:4, measure.vars = dates, variable.name = "Date", value.name = "Death")
PlotDT$Date <- as.Date(PlotDT$Date, "%m/%d/%y")

# read world population data
worldPop <- read_csv("worldPop.csv")
setDT(worldPop)

# create a row of sum of population of EU27 and combine with PlotDT, the main data table
x <- sum(worldPop[`Country Name` %in% EU27][,2]) %>% `list` ("EU27") %>% `[` (c(2,1)) %>% `t` 
colnames(x) <- c("Country Name", 2018)
worldPop <- `rbind` (worldPop, x)
PlotDT <- merge(PlotDT, worldPop, by.x = 'Country/Region', by.y = 'Country Name') 
PlotDT[`Country/Region` == "EU27"][,2:4] <- NA_character_

# calculate death per capita
PlotDT <- cbind(PlotDT, nrow(PlotDT))
PlotDT[,8] <- PlotDT[,6]/PlotDT[,7] * 1000
colnames(PlotDT)[8] <- "Deaths.per.capita"

# read the data of start of national lockdown
start_lockdown <- read_csv("lockdown.csv") %>% `[` (1:2) %>% `as.data.frame`
start_lockdown$Start <- as.Date(start_lockdown$Start, "%d/%m/%y")

# define a function for plotting graphs
myPlot <- function(countrylist, scale, type, d, slide) {
    
    # check if the user chooses the graph of Number of Death of Covid-19
    if (type == "Deaths") {
        
        # plot the graph of number of death of Covid-19
        p <- ggplot(PlotDT[is.na(`Province/State`)], aes(x = Date, y = Death, group = `Country/Region`)) + 
            geom_line(colour = "grey") + 
            geom_line(data = PlotDT[`Country/Region` %in% countrylist][is.na(`Province/State`)], aes(colour = `Country/Region`)) +
            
            # let the user choose the time frame
            scale_x_date(limits = as.Date(d)) +
            
            # let the user slide the bar to change the percentage of the most affected country
            scale_y_continuous(limits = c(NA, slide * 0.01 * max(PlotDT$Death))) +
            
            # set up the title and theme of the graph
            ggtitle("Number of Death of Covid-19", subtitle = "Source: John Hopkins University") +
            theme(text = element_text(family = "Courier"), 
            axis.line = element_line(size = 2, colour = "grey80"), 
            axis.text = element_text(colour = "blue"))
        
        # check if the user chooses logarithmic scale
        if (scale == "Logarithmic") {
            p <- p + scale_y_log10(name = "Death (logarithmic scale)", limits = c(NA, 0.01 * slide * max(PlotDT$Death)))
        }
        
        # show a line to indicate the start date of lockdown, if any
        for (i in 1:nrow(start_lockdown)) {
            if (countrylist == start_lockdown[i,1]) {
                p <- p + geom_vline(xintercept = start_lockdown[i,2], linetype = "dotdash", color = "purple") +
                    annotate("text", x = start_lockdown[i,2], y = 0.01 * slide * max(PlotDT$Death), size = 5,
                    label = "                               Start of lockdown")
            }
        }
    }
    
    # if the user doesn't choose the graph of Number of Death of Covid-19, 
    # the graph of Death per capita of Covid-19 is returned
    else {
        
        # plot the graph of death per capita of Covid-19
        p <- ggplot(PlotDT[is.na(`Province/State`)], aes(x = Date, y = Deaths.per.capita, group = `Country/Region`)) + 
            geom_line(colour = "grey") + 
            geom_line(data = PlotDT[`Country/Region` %in% countrylist][is.na(`Province/State`)], aes(colour = `Country/Region`)) +
            
            # let the user choose the time frame    
            scale_x_date(limits = as.Date(d)) +
            
            # let the user slide the bar to change the percentage of the the most affected country
            scale_y_continuous(name = "Death per capita [‰]", limits = c(NA, slide * 0.01)) +
            
            # set up the title and theme of the graph
            ggtitle("Death per capita of Covid-19 [‰]", subtitle = "Source: John Hopkins University") +
            theme(text = element_text(family = "Courier"), 
            axis.line = element_line(size = 2, colour = "grey80"), 
            axis.text = element_text(colour = "blue"))
        
        # check if the user chooses logarithmic scale
        if (scale == "Logarithmic") {
            p <- p + scale_y_log10(name = "Death per capita (logarithmic scale) [‰]", 
                limits = c(NA, 0.01 * slide))
        }
        
        # show a line to indicate the start date of lockdown, if any
        for (i in 1:nrow(start_lockdown)) {
            if (countrylist == start_lockdown[i,1]) {
                p <- p + geom_vline(xintercept = start_lockdown[i,2], linetype = "dotdash", color = "purple") +
                    annotate("text", x = start_lockdown[i,2], y = 0.01 * slide, size = 5, 
                    label = "                               Start of lockdown")
            }
        }
    }
    return(p)
}

# Define UI for application 
ui <- fluidPage(
    
    # define theme and title of the panel of shiny app
    theme = shinytheme("darkly"),
    titlePanel("Death of Covid-19"),
    sidebarLayout(
        sidebarPanel(
            
            # define inputs on UI
            selectInput("country", "Choose a Country:", choices = coronaD[,2]),
            sliderInput("slide", "Percentage of the most affected country:", min = 0, max = 100, post = "%", value = 100, animate = T),
            radioButtons("scale", "Scale:", choices = list("Linear", "Logarithmic")),
            radioButtons("deaths", "Deaths:", choices = list("Deaths", "Deaths per capita [‰]")),
            dateRangeInput("date", "Date:", start = "2020-01-22")
        ),
        mainPanel(
            plotOutput("myPlot")
        )
    )
)

# Define server logic 
server <- function(input, output) {
    output$myPlot <- renderPlot({
        myPlot(input$country, input$scale, input$deaths, input$date, input$slide)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
