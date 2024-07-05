FROM docker.io/rocker/geospatial:4.3.3

RUN apt update && apt install -y --no-install-recommends python3-pip libglpk-dev

RUN pip3 install radian

RUN install2.r languageserver \
    httpgd \
    jsonlite \
    here