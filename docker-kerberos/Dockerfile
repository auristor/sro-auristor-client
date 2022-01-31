ARG IMAGE=localhost:5000/auristor-sro-kvc:latest

FROM $IMAGE
WORKDIR /build/

ADD krb5.conf /etc/krb5.conf

RUN dnf install -y krb5-workstation
RUN dnf clean all
RUN rm -rf /var/cache/yum
