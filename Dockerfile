FROM fefelovgroup/pg9.4-client
MAINTAINER Andy Fefelov <andy@fefelovgroup.com>

RUN rm -f /etc/service/sshd/down

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && apt-get purge -y --auto-remove ca-certificates

RUN apt-get update \
    && apt-get install -y postgresql-common \
    && sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
    && apt-get install -y \
        postgresql-$PG_MAJOR\
        postgresql-contrib-$PG_MAJOR


RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

RUN mkdir -p /etc/my_init.d

# add postgres init file
ADD 01_init_postgresql.sh /etc/my_init.d/01_init_postgresql.sh
RUN chmod +x /etc/my_init.d/01_init_postgresql.sh

# add a baseimage PostgreSQL start script
RUN mkdir -p /var/run/postgresql \
    && chown -R postgres /var/run/postgresql
RUN mkdir /etc/service/postgresql
ADD postgresql.sh /etc/service/postgresql/run
RUN chmod +x /etc/service/postgresql/run

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /var/lib/postgresql/data

EXPOSE 5432
CMD ["/sbin/my_init"]
