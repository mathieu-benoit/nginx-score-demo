# nginx-score-demo

```bash
score-compose init \
    --no-sample \
    --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/score-compose/00-hpa.provisioners.yaml

score-compose generate score.yaml \
    --image nginxinc/nginx-unprivileged:alpine-slim

docker compose up --build -d --remove-orphans
```

```bash
score-k8s init \
    --no-sample \
    --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/score-k8s/00-hpa.provisioners.yaml

score-k8s generate score.yaml \
    --image nginxinc/nginx-unprivileged:alpine-slim

./scripts/setup-kind-cluster.sh

NAMESPACE=default
kubectl apply -f manifests.yaml -n $NAMESPACE
```