_Reference_
```bash
https://www.fatlan.com/13-07-2023-keycloak-21-install/
```
```bash
https://jeffreybostoen.be/installing-keycloak-on-ubuntu-server-22-04/
```

```cmd
/opt/keycloak/bin/kc.sh start --hostname=ubuntu01 \
    --http-enabled=true --http-port=8080 \
    --hostname-strict=false --https-port=8443 \
    --https-certificate-file=/opt/keycloak/cert/mycert.crt \
    --https-certificate-key-file=/opt/keycloak/cert/mycert.key
```

```cmd
/opt/keycloak/bin/kc.sh start --optimized --hostname=ubuntu01 --http-enabled=true --http-host=0.0.0.0
```

```ini
[Unit]
Description=Keycloak Service
After=network.target

[Service]
Type=simple
ExecStart=/opt/keycloak/bin/kc.sh start --hostname=ubuntu01 --http-enabled=true
User=keycloak
Restart=on-failure
Environment=KC_DB=postgres
Environment=KC_DB_USERNAME=keycloak
Environment=KC_DB_PASSWORD=Keycloak@!123456788910
Environment=KC_DB_URL=jdbc:postgresql://localhost:5432/keycloak
Environment=KC_DB_URL_HOST=localhost
Environment=KC_DB_URL_PORT=5432
Environment=KEYCLOAK_ADMIN=admin
Environment=KEYCLOAK_ADMIN_PASSWORD=Password#$12345

[Install]
WantedBy=multi-user.target


#

[Unit]
Description=Keycloak
After=network.target

[Service]
Type=simple
User=keycloak
Group=keycloak
ExecStart=/opt/keycloak/bin/kc.sh start --hostname=ubuntu01 --http-enabled=true --http-port=8080 --https-enabled=false --log-config=/opt/keycloak/keycloak.conf >> /var/log/keycloak/keycloak.log 2>> /var/log/keycloak/keycloak-error.log
Restart=always

# Database environment variables
Environment=KC_DB=postgres
Environment=KC_DB_USERNAME=keycloak
Environment=KC_DB_PASSWORD=Keycloak@!123456788910
Environment=KC_DB_URL_HOST=localhost
Environment=KC_DB_DATABASE=keycloak
Environment=KEYCLOAK_ADMIN=admin
Environment=KEYCLOAK_ADMIN_PASSWORD=Password#$12345

[Install]
WantedBy=multi-user.target



[Unit]
Description=Keycloak
After=network.target

[Service]
Type=simple
User=keycloak
Group=keycloak
Environment=KEYCLOAK_USER=admin
Environment=KEYCLOAK_PASSWORD=Password#$12345
ExecStart=/opt/keycloak/bin/kc.sh start --hostname=ubuntu01 --http-enabled=true --http-host=0.0.0.0 --log-file=/var/log/keycloak/keycloak.log --log-level=INFO --log-file-output=default
StandardOutput=append:/var/log/keycloak/keycloak.log
StandardError=append:/var/log/keycloak/keycloak-error.log
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
```sql
CREATE DATABASE keycloak;
CREATE USER keycloak WITH PASSWORD 'Keycloak@!123456788910';
ALTER ROLE keycloak SET client_encoding TO 'utf8';
ALTER ROLE keycloak SET default_transaction_isolation TO 'read committed';
ALTER ROLE keycloak SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
```




