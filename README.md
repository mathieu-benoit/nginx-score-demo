# nginx-score-demo

```bash
score-compose init --no-sample

score-compose generate score.yaml --image nginxinc/nginx-unprivileged:alpine-slim

docker compose up --build -d --remove-orphans
```

```bash
score-k8s init --no-sample

score-k8s generate score.yaml --image nginxinc/nginx-unprivileged:alpine-slim

./scripts/setup-kind-cluster.sh

NAMESPACE=default
kubectl apply -f manifests.yaml -n $NAMESPACE
```