FROM postgres:14
# Copy the seed_script.sql from one folder above the current in windows and copy it to the docker-entrypoint-initdb.d folder in linux container
COPY ./seed_script.sql /docker-entrypoint-initdb.d/
