FROM python:3.10-bullseye

WORKDIR /app

RUN apt-get update
RUN pip install --upgrade pip

COPY requirements.txt .
COPY app.py .

RUN pip install -r requirements.txt

EXPOSE 8081

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8081", "--server.address=0.0.0.0"]

# docker build -t siop_2025 .; docker run -p 8081:8081 -d --env-file=.env siop_2025:latest