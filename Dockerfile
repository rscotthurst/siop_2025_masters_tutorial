# Base R Shiny image
FROM rocker/shiny

# Make a directory in the container
RUN mkdir /home/shiny-app

# Install R dependencies
RUN R -e "install.packages(c('dplyr', 'ggplot2', 'gapminder'))"

# Copy the Shiny app code
COPY app.R /home/shiny-app/app.R

# Expose the application port
EXPOSE 80

# Run the R Shiny app
CMD Rscript /home/shiny-app/app.R

# docker build -t siop_2025 . && docker run -p 8180:80 -d siop_2025:latest
