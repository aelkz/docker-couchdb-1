FROM joeblackwaslike/debian:stretch

MAINTAINER Joe Black <me@joeblack.nyc>

ARG     ERLANG_VERSION
ARG     COUCHDB_VERSION
ARG     COUCHDB_RC
ARG     COUCHDB_CHECK_RELEASE


ENV     ERLANG_VERSION=${ERLANG_VERSION:-19.2}
ENV     COUCHDB_VERSION=${COUCHDB_VERSION:-2.1.0}
ENV     COUCHDB_RC=${COUCHDB_RC:-}
ENV     COUCHDB_CHECK_RELEASE=${COUCHDB_CHECK_RELEASE:-false}

LABEL   lang.erlang.version=$ERLANG_VERSION
LABEL   app.couchdb.version=$COUCHDB_VERSION
LABEL   app.couchdb.release-candidate=${COUCHDB_RC:-false}

ENV     APP couchdb
ENV     USER $APP
ENV     HOME /opt/$APP

COPY    build.sh /tmp/
RUN     /tmp/build.sh

COPY    build/50-couchdb-functions.sh /etc/profile.d/
COPY    build/couchdb-helper /usr/local/bin/

COPY    entrypoint /

ENV     ERL_MAX_PORTS 65536
ENV     COUCHDB_LOG_LEVEL info

EXPOSE  5984 5986

VOLUME  ["/volumes/couchdb/data"]

WORKDIR $HOME

SHELL       ["/bin/bash", "-lc"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD curl -f -s http://localhost:5984/_users || exit 1

ENTRYPOINT  ["/dumb-init", "--"]
CMD         ["/entrypoint"]
