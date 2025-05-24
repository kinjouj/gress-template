from nginx
WORKDIR /usr/share/nginx/html
copy public .
EXPOSE 80
