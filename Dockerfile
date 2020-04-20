FROM debian:latest

RUN set -ex; \
  apt-get update; \
  apt-get -y install man vim sudo; \
  apt-get -y install postgresql
  # Got postgresql version 11.7 at 20 April 2020

# Start postgresql service -- the database server daemon
RUN service postgresql start

# Switch to postgres system user that has full admin access to the service
RUN sudo -u postgres -i

# Create database
RUN createdb aftognosia

# Create the data model
RUN psql -c 'CREATE TABLE unit (unit_id text PRIMARY KEY, unit_name text, valid_from timestamp with time zone, valid_until timestamp with time zone) ' aftognosia

# Open port 5432 for postgresql
# Assumption: root account


