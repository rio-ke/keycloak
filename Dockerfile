FROM ubuntu:latest
RUN apt update && apt install nginx -y
RUN rm -rf etc/nginx/sites-enabled/default
COPY proxy.conf /etc/nginx/sites-enabled/proxy.conf
RUN mkdir -p /etc/nginx/ssl-certificate
COPY dcm4che.januo.io/bundle.crt /etc/nginx/ssl-certificate/bundle.crt
COPY dcm4che.januo.io/certificate.crt /etc/nginx/ssl-certificate/certificate.crt
COPY dcm4che.januo.io/key.key /etc/nginx/ssl-certificate/key.key
RUN ln -sf /dev/stdout /var/log/nginx/dcm4che.januo.io.access.log \
        && ln -sf /var/log/nginx/dcm4che.januo.io.error.log 
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
