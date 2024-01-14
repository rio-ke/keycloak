FROM ubuntu:latest
RUN apt update && apt upgrade -y && apt install nginx -y
RUN rm -rf etc/nginx/sites-enabled/default
COPY main.conf /etc/nginx/sites-enabled/main.conf
RUN mkdir -p /var/www/html/dcm4che/
COPY index.html /var/www/html/dcm4che/
RUN mkdir -p /etc/nginx/certs/
COPY domain-cert/ca_bundle.crt /etc/nginx/certs/ca_bundle.crt
COPY domain-cert/certificate.crt /etc/nginx/certs/certificate.crt
COPY domain-cert/private.key /etc/nginx/certs/private.key
RUN ln -sf /dev/stdout /var/log/nginx/dcm4che.januo.io.access.log \
        && ln -sf /var/log/nginx/dcm4che.januo.io.error.log 
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
