# parent image
FROM python:3.7

EXPOSE 5000

ENV PYTHONUNBUFFERED 1

COPY ./escom-hotel escom-hotel/

WORKDIR /escom-hotel

# install FreeTDS and dependencies
RUN apt-get update && \
    apt-get install unixodbc  \ 
    unixodbc-dev freetds-dev freetds-bin tdsodbc -y && \
    apt-get install --reinstall build-essential -y


# Installing flask dependencies
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r requirements.txt


RUN echo "[FreeTDS]\n\
Description = FreeTDS Driver\n\
Driver = /usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so\n\
Setup = /usr/lib/x86_64-linux-gnu/odbc/libtdsS.so" >> /etc/odbcinst.ini

ENV PATH="/py/bin:$PATH"

