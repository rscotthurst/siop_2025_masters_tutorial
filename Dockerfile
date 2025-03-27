# Base R Shiny image
FROM rocker/shiny

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R dependencies
RUN R -e "install.packages('paws', repos = c(pawsr = 'https://paws-r-builds.s3.amazonaws.com/packages/latest/', CRAN = 'https://cloud.r-project.org'))"
RUN R -e "install.packages(c('dplyr', 'ggplot2', 'dotenv', 'curl', 'shinycssloaders'))"

# Copy the Shiny app code
COPY app.R app.R
COPY sample-data.csv sample-data.csv

# Expose the application port
EXPOSE 80

# Run the R Shiny app
CMD ["Rscript", "app.R"]

# docker build --platform linux/x86_64 -t siop_2025 . && docker run --env-file .env -p 8180:80 -d siop_2025:latest
