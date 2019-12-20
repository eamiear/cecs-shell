#!/bin/bash

N_ENV="gcc gcc-c++ zlib zlib-devel pcre pcre-devel openssl openssl-devel"
N_URL="http://nginx.org/download/nginx-1.15.9.tar.gz"
N_FILE="nginx-1.15.9.tar.gz"
N_DIR="nginx-1.15.9"
N_PATH="nginx1159"
N_PREFIX="/usr/local/nginx1159"
PROJ_URL="https://github.com/ob-cloud/cecs/releases/download/cecs-v1.0.2/release.rar"
PROJ_FILE="release.rar"
PROJ_DIR="release"
PROJ="cecs"

setConfig() {
  echo "\033[32m create directory： vconfigs & $PROJ \033[0m"
  mkdir -p $N_PREFIX/conf/vconfigs
  mkdir -p $N_PREFIX/html/$PROJ

  cd $N_PREFIX/html/$PROJ
  echo "\033[32m download release file \033[0m"
  wget -c $PROJ_URL
  tar -zxvf $PROJ_FILE
  rm -f $PROJ_FILE
  cp -r/$PROJ_DIR/** $PROJ
  rm -rf $PROJ_DIR
  cd $N_PREFIX

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

echo "\033[32m setting $PROJ nginx config file \033[0m"
cat >$N_PREFIX/conf/vconfigs/$PROJ.nginx.conf<<EOF
  server {
    listen       80;
    server_name  localhost;
    location /$PROJ {
        root  html;
        index  index.html index.htm;
    }
  }
EOF
}

chkNgCfgAndReload() {
  echo "\033[32m check nginx config file and reload \033[0m"
  $N_PREFIX/sbin/nginx -t
  if [ $? -eq 0];then
    $N_PREFIX/sbin/nginx -s reload
  else
    echo -e "\033[32m Please check nginx config file \033[0m"
    exit
  fi
}

chkNgCfgAndRestart() {
  echo "\033[32m check nginx config file and restart \033[0m"
  $N_PREFIX/sbin/nginx -t
  if [ $? -eq 0];then
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
    cd /usr/local
    mkdir $N_PATH   # nginx directory
    wget -c $N_URL  # nginx source file
    tar -zxvf $N_FILE # depress source file
    mv $N_FILE $N_DIR # rename folder name
    rm -f $N_FILE  # remove source file
    cd $N_DIR
    ./configure --prefix=N_PREFIX --with-http_ssl_module

  if [ $? -eq 0 ];then
    echo "\033[32m Nginx server is compiling \033[0m"
    make && make install
    echo "\033[32m The nginx server installs successfully \033[0m"
  else
    echo "\033[32m The nginx server install failed, please check \033[0m"
    exit
  fi

  chkNgCfgAndRestart
  setConfig
  chkNgCfgAndReload
}

main
