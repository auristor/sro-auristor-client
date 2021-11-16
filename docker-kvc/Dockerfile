ARG IMAGE=dariaphoebe/auristor-sro:latest

FROM $IMAGE
WORKDIR /build/

ADD auristor-client-lib.sh /usr/lib/kvc/auristor-client-lib.sh
ADD auristor-client.conf /etc/kvc/auristor-client.conf
ADD auristor-client-wrapper.sh /usr/lib/kvc/auristor-client-wrapper.sh
