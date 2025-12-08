FROM alpine:3.20
  
RUN apk add --no-cache nginx

RUN rm -rf /usr/share/nginx/html/* \
    /var/log/nginx/* \
    /etc/nginx/*.default \
    /etc/nginx/conf.d/default.conf

COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
