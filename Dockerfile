FROM jwilder/nginx-proxy:alpine
COPY ./nginx.tmpl /app/nginx.tmpl
RUN { \
      echo 'client_max_body_size 0;'; \
    } > /etc/nginx/conf.d/unrestricted_client_body_size.conf