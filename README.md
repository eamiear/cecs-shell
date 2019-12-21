# cecs.sh

> 校园节能监控系统相关环境启动脚本

## 包含功能

1. 自动安装nginx编译环境
2. 自动下载安装nginx服务
3. 自定生成SSL证书
4. 自动启动防火墙端口
5. 自动下载cecs发布包
6. 自动配置前端nginx配置
7. 自动配置后端nginx配置

## 使用

```shell
chmod 777 cecs.sh

./cecs.sh
```

## 运行效果

```java
[root@iZbp19xg5vv2b5wnt0avavZ k]# ./cecs.sh
 Shell is starting.
 The nginx server was already installed, please exit.
 Create directory： vconfigs & cecs
 Fetching release file from github server
--2019-12-21 11:18:15--  https://github.com/ob-cloud/cecs/releases/download/cecs-v1.0.2/release.tar.gz
Resolving github.com... 13.250.177.223
Connecting to github.com|13.250.177.223|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://github-production-release-asset-2e65be.s3.amazonaws.com/225797522/eec87500-2328-11ea-9fbc-aa5323b3c660?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20191221%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20191221T031818Z&X-Amz-Expires=300&X-Amz-Signature=84d844abc39794b7353cb83f64aef7d913ac5894354886ef241cb188690d9cc7&X-Amz-SignedHeaders=host&actor_id=0&response-content-disposition=attachment%3B%20filename%3Drelease.tar.gz&response-content-type=application%2Foctet-stream [following]
--2019-12-21 11:18:20--  https://github-production-release-asset-2e65be.s3.amazonaws.com/225797522/eec87500-2328-11ea-9fbc-aa5323b3c660?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20191221%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20191221T031818Z&X-Amz-Expires=300&X-Amz-Signature=84d844abc39794b7353cb83f64aef7d913ac5894354886ef241cb188690d9cc7&X-Amz-SignedHeaders=host&actor_id=0&response-content-disposition=attachment%3B%20filename%3Drelease.tar.gz&response-content-type=application%2Foctet-stream
Resolving github-production-release-asset-2e65be.s3.amazonaws.com... 52.217.36.44
Connecting to github-production-release-asset-2e65be.s3.amazonaws.com|52.217.36.44|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2655799 (2.5M) [application/octet-stream]
Saving to: “release.tar.gz”

100%[==================================================================================================================================================>] 2,655,799   11.3K/s   in 3m 17s

2019-12-21 11:21:40 (13.1 KB/s) - “release.tar.gz” saved [2655799/2655799]

./
./css/
./css/app.2b3ceff0.css
./css/chunk-06e5d8c0.fe581b6d.css
./css/chunk-2750fa7e.5094ae5b.css
./css/chunk-2c452a31.b5156a9e.css
./css/chunk-585b5201.bff1f253.css
./css/chunk-5c61adec.9b940270.css
./css/chunk-646ad7d2.8eaaf212.css
./css/chunk-74fb70e7.4607a112.css
./css/chunk-e1cc01a4.db744d3a.css
./css/chunk-vendors.ddd2a65b.css
./favicon.ico
./fonts/
./fonts/element-icons.535877f5.woff
./fonts/element-icons.732389de.ttf
./fonts/iconfont.4916f988.eot
./fonts/iconfont.ce8f1709.ttf
./fonts/iconfont.e1acc7d1.woff
./img/
./img/background.ed09dbcc.svg
./img/iconfont.ad87cb82.svg
./index.html
./js/
./js/app.b2c0808c.js
./js/app.b2c0808c.js.map
./js/chunk-06e5d8c0.c4526a4d.js
./js/chunk-06e5d8c0.c4526a4d.js.map
./js/chunk-2750fa7e.362c3bba.js
./js/chunk-2750fa7e.362c3bba.js.map
./js/chunk-2c452a31.0378ae8b.js
./js/chunk-2c452a31.0378ae8b.js.map
./js/chunk-2d0e5357.439f6081.js
./js/chunk-2d0e5357.439f6081.js.map
./js/chunk-2d21f86d.4b00da28.js
./js/chunk-2d21f86d.4b00da28.js.map
./js/chunk-585b5201.c947ec20.js
./js/chunk-585b5201.c947ec20.js.map
./js/chunk-5c61adec.48979c59.js
./js/chunk-5c61adec.48979c59.js.map
./js/chunk-646ad7d2.8622fab1.js
./js/chunk-646ad7d2.8622fab1.js.map
./js/chunk-6cac33b4.4954ba07.js
./js/chunk-6cac33b4.4954ba07.js.map
./js/chunk-74fb70e7.28412603.js
./js/chunk-74fb70e7.28412603.js.map
./js/chunk-7b724b06.9985d884.js
./js/chunk-7b724b06.9985d884.js.map
./js/chunk-e1cc01a4.9223db19.js
./js/chunk-e1cc01a4.9223db19.js.map
./js/chunk-vendors.ce25e617.js
./js/chunk-vendors.ce25e617.js.map
./logo.png
./polyfill.js
 Server Key Creating...
 [key] Create server key.
Generating RSA private key, 2048 bit long modulus
....................+++
......................................+++
e is 65537 (0x10001)
 [csr] Create server certificate signing request.
 [ca] Sign SSL certificate.
 [crt] Sign SSL certificate.
Signature ok
subject=/C=HK/ST=Hongkong/L=Hongkong/O=NASA/OU=DEV/CN=cecs
Getting CA Private Key
TODO:
Copy cecs.crt to ../ssl/cecs.crt
Copy cecs.key to ../ssl/cecs.key
Add configuration in nginx:
server {
    ...
    listen 443 ssl;
    ssl_certificate     ../ssl/cecs.crt;
    ssl_certificate_key ../ssl/cecs.key;
}
 Detecting port 443.
tcp        0      0 0.0.0.0:443                 0.0.0.0:*                   LISTEN      15581/nginx
 Port 443 already exists
 Setting nginx base config file
 Nginx base config file is set successfully
 Setting cecs nginx config file
 cecs nginx config file is set successfully
 Setting cecs server nginx config file
 cecs server nginx config file is set successfully
 Check nginx config file and reload
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
 nginx will reload
 Shell is executed.
```
