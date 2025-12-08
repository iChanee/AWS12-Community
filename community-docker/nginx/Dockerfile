FROM alpine:3.20
  
RUN apk add --no-cache nginx

# conf.d 대신 http.d 사용
RUN rm -rf /usr/share/nginx/html/* \
    /var/log/nginx/* \
    /etc/nginx/*.default \
    /etc/nginx/http.d/default.conf

COPY conf.d/default.conf /etc/nginx/http.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
