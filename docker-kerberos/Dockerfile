ARG IMAGE=dariaphoebe/auristor-config-yfs-sro:latest

FROM $IMAGE
WORKDIR /build/

ADD krb5.conf /etc/krb5.conf

RUN dnf install -y krb5-workstation
