FROM python:3.9-slim-buster

# updating pip
RUN pip install --no-cache-dir --upgrade pip

# Installing deps for PostgreSQL
RUN apt-get update && apt-get install -y postgresql postgresql-contrib

#installing essential
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installing deps DBT
RUN pip install dbt-postgres 

# Setting PostgreSQL
USER postgres
RUN /etc/init.d/postgresql start && \
    createuser --createdb dbtuser && \
    psql --command "CREATE USER postgres WITH SUPERUSER PASSWORD 'root';" && \
    createdb -O dbtuser dbt || true

WORKDIR /usr/src/app

# Copying deps
COPY oaknorthbank_lcgosi/dbt_project.yml ./ 
COPY oaknorthbank_lcgosi/profiles.yml ./
COPY . .

EXPOSE 5432

CMD ["dbt", "run"]
