ARG IMAGE=localhost:5000/ubi

FROM $IMAGE
WORKDIR /build/

# Expecting kmod software version as an input to the build
ARG KMOD_SOFTWARE_VERSION=2021.05
ARG KMOD_RELEASE=10
# Expecting kernel version as an input to the build
#ARG KVER

ADD AURISTOR-GPG-KEY-v1 .

ADD auristor.repo /etc/yum.repos.d/auristor.repo

ADD firewalld-filesystem-0.9.3-7.el8.noarch.rpm .

ADD kmod-yfs-nokernel-${KMOD_SOFTWARE_VERSION}-${KMOD_RELEASE}.noarch.rpm .

RUN echo v$KMOD_SOFTWARE_VERSION > /etc/dnf/vars/auristorver && \
    rpm --import AURISTOR-GPG-KEY-v1   && \   
    rpm -Uvh firewalld-filesystem-0.9.3-7.el8.noarch.rpm && \
    rpm -Uvh kmod-yfs-nokernel-${KMOD_SOFTWARE_VERSION}-${KMOD_RELEASE}.noarch.rpm && \
    dnf install -y yfs yfs-client
