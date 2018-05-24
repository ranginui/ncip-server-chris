FROM debian:stretch-slim
MAINTAINER Kyle M Hall <kyle@bywatersolutions.com>

ENV PERL5LIB /kohalib
ENV KOHA_CONF /koha-conf.xml
ENV NCIP_PORT 3000

RUN apt-get -y update
RUN apt-get -y install wget gnupg2 coreutils cpanminus make
RUN wget -q -O- https://debian.koha-community.org/koha/gpg.asc | apt-key add -
RUN echo 'deb http://debian.koha-community.org/koha stable main' | tee /etc/apt/sources.list.d/koha.list

RUN apt-get update -y \
    && apt-get -y install \
       koha-perldeps \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/api/lists/*

WORKDIR /app
COPY . .
COPY ./docker/files/config.yml.template ./config.yml
COPY docker/files/log4perl.conf.template t/config_sample/log4perl.conf

RUN cpanm -n Module::Install
RUN cpanm -n --installdeps .

CMD plackup -s Gazelle --port $NCIP_PORT --max-reqs-per-child 50000 -E production -a bin/ncip_dancing.pl
