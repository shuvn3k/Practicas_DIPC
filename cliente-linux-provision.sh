#!/bin/bash


# Obtenemos el certificado SSL desde git al cliente
mkdir -p /etc/pki/tls/certs
curl -O https://raw.githubusercontent.com/ivanathletic/Practicas_DIPC/master/sync/logstash-forwarder.crt

mv logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt


# Instalamos filebeat
echo "deb https://packages.elastic.co/beats/apt stable main" | sudo tee -a /etc/apt/sources.list.d/beats.list
apt-get update
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get -y --allow-unauthenticated install filebeat


# Editamos el fichero de configuracion de filebeat
sed -i 's/\- \/var\/log\/\*.log/\- \/var\/log\/auth.log\n        \- \/var\/log\/syslog/' /etc/filebeat/filebeat.yml

sed -i 's/#document\_type\: log/document\_type\: syslog/' /etc/filebeat/filebeat.yml

sed -i '/elasticsearch:/,/\"\]/d' /etc/filebeat/filebeat.yml

# Descomentamos la seccion de logstash añadiendo la parte de tls
sed -i 's/\#logstash:/logstash:\n    hosts: ["192.168.34.150:5044"]\n    bulk_max_size: 1024\n    tls:\n      certificate_authorities: ["\/etc\/pki\/tls\/certs\/logstash-forwarder.crt"]/'  /etc/filebeat/filebeat.yml

# Reiniciamos filebeat
systemctl restart filebeat
systemctl enable filebeat
