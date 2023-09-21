FROM rocker/r-ver:4.3.1

COPY . /usr/local/src/input
WORKDIR /usr/local/src/input

ENV SNAPSHOT_DATE="2023-09-20"
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    zlib1g-dev \
    && Rscript setup.R

CMD Rscript bench.R

