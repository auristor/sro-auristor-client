ARG IMAGE=localhost:5000/auristor-sro:latest

FROM $IMAGE
WORKDIR /build/

RUN dnf install -y git make
RUN git clone https://github.com/kmods-via-containers/kmods-via-containers.git

WORKDIR kmods-via-containers

RUN make install DESTDIR=/usr/local CONFDIR=/etc/

RUN dnf remove -y git make
RUN dnf clean all
RUN rm -rf /var/cache/yum
