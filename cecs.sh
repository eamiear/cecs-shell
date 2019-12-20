#!/bin/bash

# B_PREFIX="/usr/local"
B_PREFIX="/home/k"
N_ENV="gcc gcc-c++ zlib zlib-devel pcre pcre-devel openssl openssl-devel"
N_URL="http://nginx.org/download/nginx-1.15.9.tar.gz"
N_FILE="nginx-1.15.9.tar.gz"
N_DIR="nginx-1.15.9"
N_PATH="nginx1159"
N_PREFIX="/home/k/nginx1159"
PROJ_URL="https://github.com/ob-cloud/cecs/releases/download/cecs-v1.0.2/release.tar.gz"
PROJ_FILE="release.tar.gz"
PROJ="cecs"

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
    listen       80;
    server_name  localhost;
    location /$PROJ {
        root  html;
        index  index.html index.htm;
    }
  }
EOF
}

# Set Back end Nginx config
setBeNgCfg() {

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
