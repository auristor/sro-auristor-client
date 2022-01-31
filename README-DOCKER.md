This assumes you will build the docker containers on the machine running the registry, and that the registry doesn't need a login but does have an ssl cert. this will need to be changed, but it works for this

     cd docker; docker build -t localhost:5000/auristor-sro .; docker push localhost:5000/auristor-sro;     cd ../docker-kmods-via-container; docker build -t localhost:5000/auristor-sro-kmods-via-container .; docker push localhost:5000/auristor-sro-kmods-via-container; cd ../docker-kvc; docker build -t  localhost:5000/auristor-sro-kvc . ; docker push  localhost:5000/auristor-sro-kvc ; cd ../docker-kerberos/; docker build -t localhost:5000/auristor-sro-kerberos .; docker push  localhost:5000/auristor-sro-kerberos; cd ../docker-config-yfs/;  docker build -t localhost:5000/auristor-sro-config-yfs .; docker push localhost:5000/auristor-sro-config-yfs ; cd ../docker-kmod; docker build -t localhost:5000/auristor-sro-kmod .; docker push  localhost:5000/auristor-sro-kmod


