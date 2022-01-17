ARG IMAGE=localhost:5000/auristor-sro-kmods-via-container:latest

FROM $IMAGE
WORKDIR /build/

ADD auristor-client-lib.sh .
ADD auristor-client.conf .
ADD auristor-client-wrapper.sh .

RUN dnf install -y skopeo; mkdir -p /usr/lib/kvc /etc/kvc; chmod +x *sh; cp auristor-client-lib.sh /usr/lib/kvc/auristor-client-lib.sh; cp auristor-client-wrapper.sh /usr/lib/kvc/auristor-client-wrapper.sh; cp auristor-client.conf /etc/kvc/auristor-client.conf; systemctl enable kmods-via-containers@auristor-client