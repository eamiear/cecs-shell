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
  echo
  mkdir -p $N_PREFIX/conf/vconfigs
  mkdir -p $N_PREFIX/html/$PROJ

  cd $N_PREFIX/html/$PROJ
  wget -c $PROJ_URL
  tar -zxvf $PROJ_FILE
  rm -f $PROJ_FILE
  cp -r/$PROJ_DIR/** $PROJ
  rm -rf $PROJ_DIR
  cd $N_PREFIX

  # 将vconfig下的配置包含到nginx.conf
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
# 追加项目配置
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
