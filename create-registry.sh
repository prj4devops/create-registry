#!/bin/env bash
export store=/etc/docker/certs.d/192.168.1.10:8443
openssl req -x509 -nodes -newkey rsa:4096 -keyout tls.key -out tls.crt -days 365 \
 -config tls.req -extensions v3_req
yum -y install sshpass
mkdir /data
mkdir -p $store 
cp -f tls.crt $store

for i in {1..3}
  do
    sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@w$i-k8s mkdir -p $store
    sshpass -p vagrant scp tls.crt w$i-k8s:$store
done

docker run -d \
  --restart=always \
  --name registry \
  -v /root/create-registry:/certs:ro \
  -v /data:/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/tls.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/tls.key \
  -p 8443:443 \
  registry:2
