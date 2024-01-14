```cmd
docker network create keycloak
docker run --network keycloak -d --name db -e POSTGRES_DB=keycloak -e POSTGRES_USER=keycloak -e POSTGRES_PASSWORD=keycloak postgres:latest

docker run --network keycloak -d -e POSTGRES_DB=keycloak \
           -e POSTGRES_USER=keycloak \
           -e POSTGRES_PASSWORD=keycloak \
           -e DB_VENDOR=POSTGRES \
           -e DB_ADDR=db \
           -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
           -e JAVA_OPTS="-server -Xms1024m -Xmx4096m -XX:MetaspaceSize=512M -XX:MaxMetaspaceSize=1024m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true --add-exports=java.desktop/sun.awt=ALL-UNNAMED --add-exports=java.naming/com.sun.jndi.ldap=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.security=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.management/javax.management=ALL-UNNAMED --add-opens=java.naming/javax.naming=ALL-UNNAMED" \
           -p 8080:8080 \
           --name keycloak \
           quay.io/keycloak/keycloak:23.0.4 start --http-port=8080 --http-enabled=true --http-relative-path=/auth --hostname-strict-https=false --hostname-strict=true --hostname=dcm4che.januo.io  --proxy=edge

docker run --network keycloak -d --name proxy -p 80:80 -p 443:443 jjino/nginx.dcm4che.januo.io
```
```yml
---
version: "3"

services:
  keycloak:
    image: quay.io/keycloak/keycloak:23.0.4
    container_name: cloak
    restart: always
    environment:
      - DB_VENDOR=POSTGRES
      - DB_ADDR=db
      - KEYCLOAK_ADMIN=admin
      - KEYCLOAK_ADMIN_PASSWORD=admin
      - POSTGRES_DB=keycloak
      - POSTGRES_USER=keycloak
      - POSTGRES_PASSWORD=keycloak
      #- JAVA_OPTS="-server -Xms1024m -Xmx4096m -XX:MetaspaceSize=512M -XX:MaxMetaspaceSize=1024m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true --add-exports=java.desktop/sun.awt=ALL-UNNAMED --add-exports=java.naming/com.sun.jndi.ldap=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.security=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.management/javax.management=ALL-UNNAMED --add-opens=java.naming/javax.naming=ALL-UNNAMED" \
    command:
      - start
      - "--http-port=8080"
      - "--http-enabled=true"
      - "--http-relative-path=/auth"
      - "--hostname-strict-https=false"
      - "--hostname-strict=true"
      - "--hostname=dcm4che.januo.io"
      - "--proxy=edge"
    ports:
      - "8080:8080"
    depends_on:
      - db
    networks:
      - keycloak

  db:
    image: postgres:latest
    container_name: db
    restart: always
    environment:
      - POSTGRES_DB=keycloak
      - POSTGRES_USER=keycloak
      - POSTGRES_PASSWORD=keycloak
    networks:
      - keycloak

  webserver:
    image: jjino/nginx.dcm4che.januo.io
    container_name: reporxy
    restart: always
    ports:
      - "80:80"
      - "443:443"
    networks:
      - keycloak
    depends_on:
      - keycloak
networks:
  keycloak:
    name: keycloak
    driver: bridge
```

