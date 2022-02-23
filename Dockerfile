FROM postgis/postgis:14-master

RUN apt-get update && apt-get install -y gcc python-dev python-setuptools libffi-dev python3-pip
RUN pip install gsutil

COPY ./maintenance /usr/local/bin/maintenance
RUN chmod +x /usr/local/bin/maintenance/*
RUN mv /usr/local/bin/maintenance/* /usr/local/bin \
    && rmdir /usr/local/bin/maintenance
