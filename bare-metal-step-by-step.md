
keycloak-server-installation-ubuntu-22.04.md
---

Architecture

In the architecture below, I plan to implement Keycloak as a service for an organization to securely manage identity and access processes. I have designed three services to handle their respective roles in the identity management system.

![image](https://github.com/user-attachments/assets/0042d73c-ceec-4d75-a858-b0106112826d)

You need to install the dependencies for the Keycloak service.

```console
sudo apt-get update
sudo apt install curl wget vim -y
sudo apt-get install default-jdk -y
sudo apt install openjdk-21-jre -y
java -version
```

Download the keycloak package from the official site

```console
cd /opt
sudo wget -O keycloak.tar.gz https://github.com/keycloak/keycloak/releases/download/26.0.5/keycloak-26.0.5.tar.gz
sudo mkdir -p /opt/keycloak
sudo tar -xzvf keycloak.tar.gz -C /opt/keycloak --strip-components=1
sudo rm keycloak.tar.gz
```

**Configure PostgreSQL as a service and create the credentials to store Keycloak data in the PostgreSQL server**

_Install_
```console
sudo apt update
sudo apt install postgresql postgresql-contrib -y
```
```cmd
sudo systemctl start postgresql
sudo systemctl enable postgresql
```
_Config_

```cmd
sudo -i -u postgres
psql
```
```sql
CREATE DATABASE keycloak;
CREATE USER keycloak WITH PASSWORD 'Keycloak@!123456788910';
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
```
_Configure PostgreSQL to Allow Password Authentication_

```cmd
sudo vim /etc/postgresql/14/main/pg_hba.conf
```
_Change peer to md5_

```ini
local   all             all                                     md5
```
```cmd
sudo systemctl restart postgresql
```

_**Configure Nginx as a service and create two virtual hosts to access Keycloak as a domain-based web console**_

_Install_
```console
sudo apt update
sudo apt install nginx
```
```cmd
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```
_Configure SSL Certificates_

* Place your SSL certificate and key in /etc/nginx/ssl/ or another secure directory
```cmd
mkdir -p /etc/nginx/ssl/radianterp.in/
```
_Config_

```cmd
sudo vim /etc/nginx/conf.d/keycloak.conf
```
```nginx
# Redirect HTTP traffic to HTTPS
server {
    listen 80;
    server_name oauth-sso.radianterp.in;

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS server block for Keycloak reverse proxy
server {
    listen 443 ssl http2;
    server_name oauth-sso.radianterp.in;

    # SSL settings
    ssl_certificate /etc/nginx/ssl/radianterp/crt-file;
    ssl_certificate_key /etc/nginx/ssl/radianterp/key-file;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # Proxy configurations
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        
        # WebSocket support for Keycloak
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts for backend response
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        send_timeout 60s;
    }

    # Access and error logging
    access_log /var/log/nginx/oauth-sso.radianterp.in_access.log main;
    error_log /var/log/nginx/oauth-sso.radianterp.in_error.log error;

    # Gzip settings for compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_proxied any;
    gzip_min_length 1000;
    gzip_comp_level 6;
}
```
```cmd
sudo vim /etc/nginx/nginx.conf
```
* Add keycloak_format in http { log line}
  
```nginx
log_format keycloak_format '$remote_addr - $remote_user [$time_local] '
                          '"$request" $status $body_bytes_sent '
                          '"$http_referer" "$http_user_agent" '
                          '"$request_time" "$upstream_response_time" '
                          '"$host" "$request_uri"';
```

```cmd
nginx -t
```
```cmd
sudo systemctl reload nginx.service
```

**_Prepare the keycloak configuration file_**

```cmd
sudo vim keycloak.conf
```
```ini
# Basic settings for running in production. Change accordingly before deploying the server.

# Database: The database vendor.
db=postgres
db-username=keycloak
db-password=Keycloak@!123456788910
db-url=jdbc:postgresql://localhost/keycloak

# Observability: If the server should expose healthcheck endpoints and metrics endpoints.
health-enabled=true
metrics-enabled=true

# HTTP
http-enabled=true
http-host=0.0.0.0
http-port=8080

# HTTPS
# The file path to a server certificate or certificate chain in PEM format.
# https-certificate-file=${kc.home.dir}conf/server.crt.pem
# The file path to a private key in PEM format.
# https-certificate-key-file=${kc.home.dir}conf/server.key.pem

# HOSTNAME INFO
#hostname-strict=true
#hostname-backchannel-dynamic=false
hostname=oauth-sso.radianterp.in
#hostname-admin=https://admin-sso.radianterp.in

# PROXY: The proxy address forwarding mode if the server is behind a reverse proxy.
# proxy=reencrypt
proxy-headers=xforwarded

# LOGGING
log=console,file
log-file=/var/log/keycloak/events.log
spi-events-listener-jboss-logging-success-level=info
spi-events-listener-jboss-logging-error-level=info
# Do not attach route to cookies and rely on the session affinity capabilities from reverse proxy
# spi-sticky-session-encoder-infinispan-should-attach-route=false

```

_Run keycloak service as non root user_

```console
sudo groupadd keycloak
sudo useradd -r -g keycloak -d /opt/keycloak -s /sbin/nologin keycloak
sudo cp /opt/keycloak/conf/keycloak.conf,/opt/keycloak/conf/keycloak.conf.backup
sudo cp /opt/keycloak/conf/cache-ispn.xml /opt/keycloak/conf/cache-ispn.xml.backup
sudo mv keycloak.conf /opt/keycloak/conf/keycloak.conf
sudo chown -R keycloak:keycloak /opt/keycloak
sudo chmod 774 /opt/keycloak/bin
sudo mkdir -p /var/log/keycloak
sudo chown -R keycloak:keycloak /var/log/keycloak
```
```cmd
export JAVA_OPTS_KC_HEAP="-XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=30 -XX:MinRAMPercentage=50 -XX:MaxRAMPercentage=65"
```

Create the temp admin username and password to access the keycloak web console.

```console
/opt/keycloak/bin/kc.sh  bootstrap-admin user
# Enter username [temp-admin]: xxx
# Enter password [temp-admin]: xxx
```
_Run keycloak manually_

```cmd
/opt/keycloak/bin/kc.sh start --optimized
```
**_Run keycloak as systemd service_**

```console
# sudo vim /etc/systemd/system/keycloak.service
[Unit]
Description=The Keycloak Server
After=syslog.target network.target
# Before=nginx.service

[Service]
User=keycloak
Group=keycloak
LimitNOFILE=102642
PIDFile=/run/keycloak/keycloak.pid
ExecStart=/opt/keycloak/bin/kc.sh start --optimized
Environment=JAVA_OPTS_KC_HEAP="-XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=30 -XX:MinRAMPercentage=50 -XX:MaxRAMPercentage=65"
StandardOutput=file:/var/log/keycloak/standard.log
StandardError=file:/var/log/keycloak/error.log

[Install]
WantedBy=multi-user.target
```

```console
sudo systemctl daemon-reload
sudo systemctl start keycloak
sudo systemctl status keycloak
```



https://github.com/ivangfr/keycloak-clustered
