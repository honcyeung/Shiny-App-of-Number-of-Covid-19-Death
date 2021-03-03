# Shiny App of Number of Covid-19 Death

Covid-19 is one of the most fatal pandemics in mankind’s history. The world has long been pandemic-free before Covid-19 hit during the winter of 2019. Covid-19 has caused millions of infections and hundreds of thousands of death around the world. To alleviate the status quo, we must understand how serious and widespread it is. This project aims to provide more insights into the situation of the pandemic.

<p align = "center">
  <img src = "https://sfc.asso.fr/wp-content/uploads/2020/03/Logo-Covid.png"
       </p>

You may access the application via https://honchingyeung.shinyapps.io/Shiny_app/. 

The application allows users to show various graphs of the number of death of covid-19 through adjusting various parameters such as countries, percentage, scale, number of death, death per capita, and date. The data of number of death is downloaded from John Hopkins University. It contains columns of Province/State, Country/Region, Lat, Long, and the number of death of each day since the pandemic. I first change the data type of all the date columns to date data and merge them together to get the total number of death. Then I create a row of 27 EU countries as an option for showing the number of death in the Shiny application. Next the program reads the csv file of the population of each country and the start date of lockdown respectively for further calculations. NA values are assigned to blank cells.

I then calculate the total population of 27 EU countries, and the death per capita for each country and EU 27. I have defined a function for plotting graphs on the application with factors such as the number of death, scale, the choice of country, the start date of lockdown as a dotted line on the graph, if any. Lastly, the theme, texts, layout, percentage bar of the most affected country, and date are defined on the user interface.

As you can see from the application, on the left users can adjust the parameters to display graphs accordingly. The coloured line on the graph is the country the user has chosen. If there is a lockdown date, a dotted line will be shown on the graph.
