ARG IMAGE=localhost:5000/auristor-sro-config-yfs:latest

FROM $IMAGE
WORKDIR /build/

# Expecting kmod software version as an input to the build
ARG KMOD_SOFTWARE_VERSION=2021.05
ARG KMOD_RELEASE=10
# Expecting kernel version as an input to the build
ARG KVER=4.18.0_305.19.1

ADD AURISTOR-GPG-KEY-v1 .

ADD auristor.repo /etc/yum.repos.d/auristor.repo

RUN echo v$KMOD_SOFTWARE_VERSION > /etc/dnf/vars/auristorver && \
    rpm --import AURISTOR-GPG-KEY-v1   && dnf install -y cpio && \   
    dnf download $(dnf list --showduplicates kmod-yfs-${KMOD_SOFTWARE_VERSION}|grep ${KVER}|tail -1|awk '{print "kmod-yfs-" $2}') && rpm2cpio kmod-yfs*.rpm |(cd / && cpio -id \*.ko)

