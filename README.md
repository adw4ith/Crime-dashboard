\# 🧭 Crime Analysis Dashboard



An interactive Shiny web application that visualizes and explores crime data in Chicago.  

Built in R using Shiny, this dashboard helps uncover spatial and temporal patterns in urban crime — turning raw data into meaningful insights.



---



📊 Overview



The Crime Analysis Dashboard provides an intuitive interface for users to:



 - Explore trends in reported crimes over time  

 - Visualize hotspots on an interactive map  

 - Filter by year, month, or type of crime  

 - Compare categories such as theft, assault, burglary, and more  



It’s designed for both casual exploration and deeper analytical insight into urban safety patterns.



---



🖼️ Dashboard Preview



| Crime Trends View | Map Visualization | Crime Breakdown |

|:-----------------:|:-----------------:|:----------------:|

| ![Trends](Screenshots/Screenshot%202025-10-06%20204459.png) | ![Map](Screenshots/Screenshot%202025-10-06%20204601.png) | ![Breakdown](Screenshots/Screenshot%202025-10-06%20204717.png) |



---



🧠 Features



 - Interactive Filtering: Adjust crime type, time range, or region dynamically  

 - Visual Insights: Time-series graphs, maps, and bar plots for instant pattern recognition  

 - Spatial Exploration: Map view powered by `leaflet` for real-time zoom and hover data  

 - Data Transparency: Raw data table included for detailed inspection  



---



📂 Project Structure



Crime-dashboard/

 ─ Crimes\_2023.csv # Main dataset

 ─ dashboard.R # Shiny app code (UI + server)

 ─ crime.Rproj # RStudio project file

 ─ Report (1).pdf # Supporting project documentation

 ─ Screenshots/ # Dashboard screenshots

 ─ README.md # You’re reading it!



⚙️ Installation \& Running Locally

1\. Clone this repository:
&nbsp;  ```bash
&nbsp;  git clone https://github.com/adw4ith/Crime-dashboard.git
&nbsp;  cd Crime-dashboard
Install required R packages:
r
install.packages(c("shiny", "shinydashboard", "leaflet", "dplyr", "ggplot2"))

Run the app in R or RStudio:

shiny::runApp("dashboard.R")
 
The app will open automatically in your browser.

🗺️ Data Source

The data is derived from Chicago crime reports (2023) — publicly available via the City of Chicago Data Portal.
It includes fields such as crime type, location, date, and geographic coordinates (block-level).

🚀 Future Improvements

* Here are some ideas to extend the project:
* Add multi-year data for long-term trend analysis
* Integrate demographic or socioeconomic context
* Build predictive models for crime forecasting
* Deploy publicly via shinyapps.io



👨‍💻 Author

Adwaith
MSc Data Science student at the University of Limerick
📍 Focus: Data visualization, analytics, and urban informatics



If you found this project interesting, give it a ⭐ on GitHub!






