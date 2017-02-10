#!/bin/bash

#Instalamos JAVA ultima version


apt-get update
sudo apt-get -y install software-properties-common
sudo apt-get -y install python-software-properties

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java7-installer 



#sudo add-apt-repository -y ppa:/webupd8team/java
#sudo apt-get update
# sudo apt-get --force-yes install oracle-java8-installer
# echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
# apt-get install default-jre
# apt-get install default-jdk

apt-get install unzip

#Instalamos elasticsearch

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

sudo apt-get update
sudo apt-get -y install elasticsearch

#editamos el archivo de configuracion de elasticsearch
sed -i 's/\# network.host: 192.168.0.1/ network.host: localhost/' /etc/elasticsearch/elasticsearch.yml

systemctl restart elasticsearch
systemctl daemon-reload
systemctl enable elasticsearch


#instalamos kibana

echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | sudo tee -a /etc/apt/sources.list
apt-get update
apt-get -y install kibana

sed -i 's/server.host: /server.host: "localhost"/' /opt/kibana/config/kibana.yml

systemctl daemon-reload
systemctl enable kibana
systemctl start kibana

#instalamos nginx
apt-get -y install nginx
sudo -v


#creamos el usuario de kibana
echo "kibanaadmin:$apr1$PyFSkPGc$GVVIRv.hxOxyvxnxUi2Ao1'" | tee -a /etc/nginx/htpasswd.users
#echo "kibanaadmin:`openssl /etc/nginx/htpasswd.users passwd -apr1`" | sudo tee -a /etc/nginx/htpsswd.users


mv /tmp/default "/etc/nginx/sites-available/default"

nginx -t
systemctl restart nginx

ufw allow 'Nginx Full'


#Instalamos logstash
echo "deb http://packages.elastic.co/logstash/2.3/debian stable main" | tee -a /etc/apt/sources.list
apt-get update
apt-get install logstash

#creamos carpetas para el certificado
mkdir -p /etc/pki/tls/certs
mkdir /etc/pki/tls/private


sed -i 's/\[ v3_ca \]/\[ v3_ca \]\nsubjectAltName = IP:192.168.34.150/' /etc/ssl/openssl.cnf



#creamos el certificado ssl
openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt


#movemos el fichero 02-beats-input.conf a su correspondiente carpeta

mv /tmp/02-beats-input.conf /etc/logstash/conf.d/02-beats-input.conf

ufw allow 5044


#movemos el archivo 10-syslog-filter.conf a su correspondiente carpeta
mv /tmp/10-syslog-filter.conf /etc/logstash/conf.d/10-syslog-filter.conf
#movemos el archivo 30-elasticsearch-ouput.conf a su carpeta
mv /tmp/30-elasticsearch-ouput.conf /etc/logstash/conf.d/30-elasticsearch-output.conf


systemctl restart logstash
systemctl enable logstash


#instalamos los dashboards de kibana

curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.2.2.zip
unzip beats-dashboards-1.2.2.zip
sh beats-dashboards-1.2.2/load.sh


#instalamos indices para plantilla filebeat
curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json

curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json
