_Reference_
```bash
https://www.fatlan.com/13-07-2023-keycloak-21-install/
```
```bash
https://jeffreybostoen.be/installing-keycloak-on-ubuntu-server-22-04/
```

```cmd
/opt/keycloak/bin/kc.sh start --optimized --hostname=ubuntu01 --http-enabled=true --http-host=0.0.0.0
```

```ini
[Unit]
Description=Keycloak Authorization Server
After=network.target
 
[Service]
ExecStart=/opt/keycloak/bin/kc.sh start
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
```
```sql
CREATE DATABASE keycloak;
CREATE USER keycloak WITH PASSWORD 'Keycloak@!123456788910';
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
```

```ini
# Basic settings for running in production. Change accordingly before deploying the server.

# Database

# The database vendor.
db=postgres

# The username of the database user.
db-username=keycloak

# The password of the database user.
db-password=Keycloak@!123456788910

# The full database JDBC URL. If not provided, a default URL is set based on the selected database vendor.
db-url=jdbc:postgresql://localhost/keycloak

# Observability

# If the server should expose healthcheck endpoints.
health-enabled=true

# If the server should expose metrics endpoints.
metrics-enabled=true

# HTTP

# The file path to a server certificate or certificate chain in PEM format.
#https-certificate-file=${kc.home.dir}conf/server.crt.pem

# The file path to a private key in PEM format.
#https-certificate-key-file=${kc.home.dir}conf/server.key.pem

# The proxy address forwarding mode if the server is behind a reverse proxy.
#proxy=reencrypt

# Do not attach route to cookies and rely on the session affinity capabilities from reverse proxy
#spi-sticky-session-encoder-infinispan-should-attach-route=false

# Hostname for the Keycloak server.
hostname=https://sso.radianterp.in
hostname-admin=https://admin-sso.radianterp.in
hostname-strict=true
hostname-backchannel-dynamic=true

http-enabled=true
http-host=0.0.0.0
http-port=8080
proxy-headers=xforwarded



spi-events-listener-jboss-logging-success-level=info
spi-events-listener-jboss-logging-error-level=info



log=console,file
log-file=/var/log/keycloak/keycloak.log

cache=ispn
cache-metrics-histograms-enabled=true
```

```conf
server {
    listen 80;
    server_name sso.radianterp.in;

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name sso.radianterp.in;

    ssl_certificate /etc/nginx/ssl/radianterp.in/STAR_radianterp_in.chained.crt;
    ssl_certificate_key /etc/nginx/ssl/radianterp.in/private.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Websocket support (for Keycloak Admin Console)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```
```conf
server {
    listen 80;
    server_name admin-sso.radianterp.in;

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name admin-sso.radianterp.in;

    ssl_certificate /etc/nginx/ssl/radianterp.in/STAR_radianterp_in.chained.crt;
    ssl_certificate_key /etc/nginx/ssl/radianterp.in/private.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Websocket support (for Keycloak Admin Console)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```
```cmd
cd /opt/
ls
wget https://github.com/keycloak/keycloak/releases/download/26.0.5/keycloak-26.0.5.tar.gz
ls
mkdir keycloak 
tar -xzvf keycloak.tar.gz keycloak --strip-components=1
tar -xzvf keycloak-26.0.5.tar.gz keycloak --strip-components=1
ls
tar -xzvf keycloak-26.0.5.tar.gz  --strip-components=1
ls
rm -rf keycloak-26.0.5.tar.gz 
ls -la
cd themes/
ls
cat README.md 
cd 
cd ..
cd /opt/
ls
mkdir keycloak
mv LICENSE.txt keycloak/
mv README.md keycloak/
mv bin/ keycloak/
mv conf/ keycloak/
mv lib/ keycloak/
mk providers keycloak/
mv providers keycloak/
ls
mv themes keycloak/
ls
mv version.txt keycloak/
ls
java --version
apt-get install default-jdk -y
sudo apt install vim
cd keycloak/
```

```
92  bin/kc.sh start --optimized --bootstrap-admin-username=gino --bootstrap-admin-password=gino
```

