# nginx-score-demo

```bash
score-compose init --no-sample

score-compose generate score.yaml --image nginxinc/nginx-unprivileged:alpine-slim

docker compose up --build -d --remove-orphans
```