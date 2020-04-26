# Copyright 2020 Marios Fragkoulis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM debian:latest

RUN set -ex; \
  apt-get update; \
  apt-get -y install man vim git sudo;

# Got postgresql version 11.7 at 20 April 2020
RUN apt-get -y install postgresql && \
  # Start postgresql service -- the database server daemon
  service postgresql start;

RUN apt-get -y install python3 python3-psycopg2 libpq-dev python3-pip python3-venv

# Switch to postgres system user that has full admin access to the service
RUN sudo -u postgres -i
RUN psql -c "CREATE DATABASE aftognosia WITH ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0;"
# echo -n "gnothisAft0n!" | md5sum = 661c80188ae2daab61dd15c7e2692e6d
RUN psql -c "CREATE USER aftognosia WITH PASSWORD 'md5661c80188ae2daab61dd15c7e2692e6d'";
RUN psql -c "GRANT ALL PRIVILEGES ON DATABASE aftognosia TO aftognosia;"
# Database password: gnothisAft0n!
# Secuity is not a priority at the current stage.
# For production we will separate configuration from code,
# e.g. see django-environ.

# Switch to root and create aftognosia user and group
RUN exit
RUN addgroup --gid 200 aftognosia
RUN adduser --uid 200 --gid 200 --disabled-password --gecos Aftognosia aftognosia

# Switch to aftognosia user
RUN sudo -u aftognosia -i

# Create the data model
RUN psql -c "CREATE TABLE unit (unit_id text, unit_name text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY (unit_id, valid_until));" aftognosia
RUN psql -c "CREATE TABLE unit_structure (unit_id text, supervising_unit_id text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY(unit_id, valid_until));" aftognosia
RUN psql -c "CREATE TABLE employee (employee_id text, first_name text, middle_name text, last_name text, father_name text, mother_name text, birthdate date, tax_id text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY(employee_id, valid_until));" aftognosia
RUN psql -c "CREATE TABLE unit_employee (unit_id text, employee_id text, assignment_id text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY(unit_id, employee_id, valid_until));" aftognosia
RUN psql -c "CREATE TABLE expense (expense_id text PRIMARY KEY, occured_on date, inserted_at timestamp with time zone, unit_id text, employee_id text, expense_description text, amount money);" aftognosia

# Create and activate virtual environment; install Django
RUN python3 -m venv ~/.virtualenvs/djangodev && \
    source ~/.virtualenvs/djangodev/bin/activate
    pip3 install Django;



# Open port 5432 for postgresql (We will need this in swarm or :compose mode when thte databse)
# Open port 5432 for postgresql


