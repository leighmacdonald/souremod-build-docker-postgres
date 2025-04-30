FROM ubuntu:20.04 AS pg

RUN dpkg --add-architecture i386 && apt-get update
RUN apt-get install wget -y g++-multilib linux-libc-dev:i386 lib32z1-dev make

WORKDIR /build

# 14 is chosen simply because its the same version that 22.04 targets and supports SCRAM, newer ones likely work too.
RUN wget -q https://ftp.postgresql.org/pub/source/v14.17/postgresql-14.17.tar.gz && \
    tar xfz postgresql-14.17.tar.gz && \
    rm postgresql-14.17.tar.gz
WORKDIR /build/postgresql-14.17
RUN CFLAGS='-fPIC -m32' ./configure --without-readline && make -j10

FROM ubuntu:20.04

WORKDIR /buildroot/pg14

# USER root
RUN dpkg --add-architecture i386 && \
  apt update && \
  apt-get install -y clang lib32stdc++-7-dev lib32z1-dev libc6-dev-i386 linux-libc-dev:i386 g++-multilib git python3-pip wget

WORKDIR /buildroot

RUN git clone --recursive https://github.com/alliedmodders/sourcemod
RUN sourcemod/tools/checkout-deps.sh

WORKDIR /buildroot/sourcemod/build

COPY --from=pg /build/postgresql-14.17/src/interfaces/libpq/libpq.a /buildroot/sourcemod/extensions/pgsql/lib_linux/libpq.a

RUN python3 ../configure.py -s all

RUN /root/.local/bin/ambuild

CMD ["/bin/bash"]

