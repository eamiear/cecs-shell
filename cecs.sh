#!/bin/bash

# B_PREFIX="/usr/local"
B_PREFIX="/usr/local"
N_ENV="gcc gcc-c++ zlib zlib-devel pcre pcre-devel openssl openssl-devel"
N_URL="http://nginx.org/download/nginx-1.15.9.tar.gz"
N_FILE="nginx-1.15.9.tar.gz"
N_DIR="nginx-1.15.9"
N_PATH="nginx1159"
N_PREFIX="/usr/local/nginx1159"
N_SSL="/usr/local/nginx1159/conf/ssl"
PROJ_URL="https://github.com/ob-cloud/cecs/releases/download/cecs-v1.0.2/release.tar.gz"
PROJ_FILE="release.tar.gz"
PROJ="cecs"
KEY="cecs"

setFirewallPort() {
  firewall-cmd --zone=public --add-port=443/tcp –permanent
  systemctl restart firewalld.service
}

# generate ssl
genSSL() {
  if [ -d $N_SSL ];then
    echo " SSL exist"
  else
    echo "[key] Create server key..."

    # openssl genrsa -des3 -out $KEY.key 1024
    openssl genrsa -out ssl.key 2048

    echo "[csr] Create server certificate signing request..."

    SUBJECT="/C=HK/ST=Hongkong/L=Hongkong/O=NASA/OU=DEV/CN=$KEY"

    openssl req -new -key $KEY.key -out $KEY.csr -subj $SUBJECT

    # echo "Remove password..."

    # mv $KEY.key $KEY.origin.key
    # openssl rsa -in $KEY.origin.key -out $KEY.key

    echo "[ca] Sign SSL certificate..."
    openssl req -new -x509 -key $KEY.key -out $KEY.ca.crt -days 3650 -subj $SUBJECT

    echo "[crt] Sign SSL certificate..."

    openssl x509 -req -days 3650 -in $KEY.csr -CA $KEY.ca.crt -CAkey $KEY.key -CAcreateserial -out $KEY.crt

    echo "TODO:"
    echo "Copy $KEY.crt to ../ssl/$KEY.crt"
    echo "Copy $KEY.key to ../ssl/$KEY.key"
    echo "Add configuration in nginx:"
    echo "server {"
    echo "    ..."
    echo "    listen 443 ssl;"
    echo "    ssl_certificate     ../ssl/$KEY.crt;"
    echo "    ssl_certificate_key ../ssl/$KEY.key;"
    echo "}"
  fi
}

# Nginx base config
setBaseNgCfg() {
echo "\033[32m setting nginx config file \033[0m"
cat >$N_PREFIX/conf/nginx.conf<<EOF
  worker_processes  1;
  events {
      worker_connections  1024;
  }
  http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    include   vconfigs/*;
  }
EOF
}
# Set Front end Nginx config
setFeNgCfg() {
echo "\033[32m setting $PROJ nginx config file \033[0m"
cat >$N_PREFIX/conf/vconfigs/$PROJ.nginx.conf<<EOF
  server {
    listen       443 ssl;
    server_name  localhost;

    ssl_certificate ./ssl/$KEY.crt;
    ssl_certificate_key ./ssl/$KEY.key;

    charset utf-8;
    location /$PROJ {
        root  html;
        index  index.html index.htm;
    }
  }
EOF
}

# Set Back end Nginx config
setBeNgCfg() {
echo "\033[32m setting $PROJ server nginx config file \033[0m"
cat >$N_PREFIX/conf/vconfigs/$PROJ.server.nginx.conf<<EOF
  server {
       listen       443 ssl;
       server_name  localhost;

       ssl_certificate ./ssl/$KEY.crt;
       ssl_certificate_key ./ssl/$KEY.key;

       charset utf-8;
       location / {
            root   html;
            index  index.html index.htm;
            proxy_pass        https://zuul_server;
			      proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Port $Server_port;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_connect_timeout 60000;
            proxy_read_timeout 60000;
            proxy_send_timeout 60000;
            proxy_intercept_errors off;
        }
        # location /cecs {
        #   root html;
        #   index index.html index.htm;
        # }
    }
EOF
}
# Set Nginx Config file
setConfig() {
  echo "\033[32m Create directory： vconfigs & $PROJ \033[0m"
  mkdir -p $N_PREFIX/conf/vconfigs
  mkdir -p $N_PREFIX/html/$PROJ

  cd $N_PREFIX/html/$PROJ   # /usr/local/nginx1159/html/cecs
  rm -rf ./*

  echo "\033[32m download release file \033[0m"

  wget -c $PROJ_URL   # download project realease.tar.gz
  tar -zxvf $PROJ_FILE # depress realease file
  rm -f $PROJ_FILE
  cd $N_PREFIX

genSSL

setFirewallPort

setBaseNgCfg

setFeNgCfg

setBeNgCfg
}

# Check Nginx config file and reload
chkNgCfgAndReload() {
  echo "\033[32m check nginx config file and reload \033[0m"
  $N_PREFIX/sbin/nginx -t
  if [ $? -eq 0 ];then
    #echo "\033[32m nginx will reload \033[0m"
    $N_PREFIX/sbin/nginx -s reload
  else
    echo -e "\033[32m Please check nginx config file \033[0m"
    exit
  fi
}

# Check Nginx config file and restart
chkNgCfgAndRestart() {
  echo "\033[32m check nginx config file and restart \033[0m"

  $N_PREFIX/sbin/nginx -t

  if [ $? -eq 0 ];then
    #echo "\033[32m nginx will restart \033[0m"
    pkill nginx
    $N_PREFIX/sbin/nginx
  else
    echo -e "\033[32m Please check nginx config file \033[0m"
    exit
  fi
}

main() {
  if [ -d $N_PREFIX ];then
    echo -e "\033[32m The nginx server was already installed, please exit. \033[0m"
    setConfig
    chkNgCfgAndReload

  else
    echo -e "\033[32m Nginx server isn't installed! \033[0m"
    echo -e "\033[32m Nginx server installing... \033[0m"
    yum install -y $N_ENV
    cd $B_PREFIX    # /usr/local
    mkdir $N_PATH   # nginx directory - nginx1159
    wget -c $N_URL  # nginx source file - nginx-1.15.9.tar.gz
    tar -zxvf $N_FILE # depress source file -> nginx-1.15.9
    #rm -f $N_FILE  # remove source file
    cd $N_DIR   # /usr/local/nginx-1.15.9
    ./configure --prefix=$N_PREFIX --with-http_ssl_module

    if [ $? -eq 0 ];then
      echo "\033[32m Nginx server is compiling \033[0m"
      make && make install
      echo "\033[32m The nginx server installs successfully \033[0m"
    else
      echo "\033[32m The nginx server install failed, please check \033[0m"
      exit
    fi

    echo "\033[32m Remove $N_DIR \033[0m"
    cd ..
    rm -rf $N_DIR

    chkNgCfgAndRestart
    setConfig
    chkNgCfgAndReload
  fi
}

main
