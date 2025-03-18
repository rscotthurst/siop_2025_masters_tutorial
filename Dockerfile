# Base R Shiny image
FROM rocker/shiny

# Install R dependencies
RUN R -e "install.packages(c('dplyr', 'ggplot2', 'gapminder'))"

# Copy the Shiny app code
COPY app.R app.R

# Expose the application port
EXPOSE 80

# Run the R Shiny app
CMD ["Rscript", "app.R"]

# docker build --platform linux/x86_64 -t siop_2025 . && docker run -p 8180:80 -d siop_2025:latest
