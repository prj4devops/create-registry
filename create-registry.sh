#!/bin/sh
openssl req -x509 -nodes -newkey rsa:4096 -keyout tls.key -out tls.crt -days 365 \
 -config tls.req -extensions v3_req

yum -y install sshpass
mkdir -p /etc/docker/certs.d/192.168.1.10:8443
cp -f tls.crt /etc/docker/certs.d/192.168.1.10:8443
sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@w1-k8s \
mkdir -p /etc/docker/certs.d/192.168.1.10:8443
sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@w2-k8s \
mkdir -p /etc/docker/certs.d/192.168.1.10:8443
sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@w3-k8s \
mkdir -p /etc/docker/certs.d/192.168.1.10:8443
sshpass -p vagrant scp tls.crt w1-k8s:/etc/docker/certs.d/192.168.1.10:8443
sshpass -p vagrant scp tls.crt w2-k8s:/etc/docker/certs.d/192.168.1.10:8443
sshpass -p vagrant scp tls.crt w3-k8s:/etc/docker/certs.d/192.168.1.10:8443

mkdir -p /data
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
