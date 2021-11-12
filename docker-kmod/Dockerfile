ARG IMAGE=hub.docker.com:dariaphoebe.auristor-sro:latest

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
    rpm --import AURISTOR-GPG-KEY-v1   && \   
    dnf download kmod-yfs-${KMOD_SOFTWARE_VERSION}-${KVER}.${KMOD_RELEASE}.el8.x86_64.rpm && rpm2cpio kmod-yfs-${KMOD_SOFTWARE_VERSION}-${KVER}.${KMOD_RELEASE}.el8.x86_64.rpm |(cd / && cpio -id \*.ko)
