# Pull base image
FROM r-base

# Install Crucial system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install `pak` using basic installer
RUN R -q -e 'install.packages("pak")'

# Use `pak` to install shiny
RUN R -q -e 'pak::pak("shiny")'

# Set working directory and copy over app
WORKDIR /app
COPY app.R .

# Expose our port
EXPOSE 80

# Run shiny!
ENTRYPOINT ["R", "-e", "shiny::runApp('app.R', port=80, host='0.0.0.0')"]

# docker build -t siop_2025 . && docker run -p 80:80 -d --env-file=.env siop_2025:latest

# docker build -t siop_2025 . && docker run -ti --rm siop_2025
