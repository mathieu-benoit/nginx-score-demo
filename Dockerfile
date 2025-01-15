FROM nginxinc/nginx-unprivileged:alpine-slim
COPY website/ /usr/share/nginx/html