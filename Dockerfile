FROM debian:latest

RUN set -ex; \
  apt-get update; \
  apt-get -y install man vim sudo;

# Got postgresql version 11.7 at 20 April 2020
RUN apt-get -y install postgresql && \
  # Start postgresql service -- the database server daemon
  service postgresql start;

RUN apt-get -y install python3 python3-psycopg2 libpq-dev python3-pip python3-venv;

# Switch to postgres system user that has full admin access to the service
RUN sudo -u postgres -i

RUN python3 -m venv ~/.virtualenvs/djangodev && \
    source ~/.virtualenvs/djangodev/bin/activate
    pip3 install Django;

# Create database
RUN createdb aftognosia

# Create the data model
RUN psql -c 'CREATE TABLE unit (unit_id text, unit_name text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY (unit_id, valid_until));' aftognosia
RUN psql -c 'CREATE TABLE unit_structure (unit_id text, supervising_unit_id text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY(unit_id, valid_until));' aftognosia
RUN psql -c 'CREATE TABLE employee (employee_id text, first_name text, middle_name text, last_name text, father_name text, mother_name text, birthdate date, tax_id text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY(employee_id, valid_until));' aftognosia
RUN psql -c 'CREATE TABLE unit_employee (unit_id text, employee_id text, assignment_id text, valid_from timestamp with time zone, valid_until timestamp with time zone, PRIMARY KEY(unit_id, employee_id, valid_until));' aftognosia
RUN psql -c 'CREATE TABLE expense (expense_id text PRIMARY KEY, occured_on date, inserted_at timestamp with time zone, unit_id text, employee_id text, expense_description text, amount money);' aftognosia


# Open port 5432 for postgresql
# Assumption: root account


