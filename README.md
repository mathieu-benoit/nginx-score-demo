# nginx-score-demo

## Deploy with `score-compose`

```bash
score-compose init \
    --no-sample \
    --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/score-compose/00-hpa.provisioners.yaml

score-compose generate score.yaml \
    --image nginxinc/nginx-unprivileged:alpine-slim

echo '{"services":{"nginx-webapp":{"read_only":"true","user":"65532","cap_drop":["ALL"]}}}' | yq e -P > compose.override.yaml

docker compose up --build -d --remove-orphans

curl $(score-compose resources get-outputs dns.default#nginx.dns --format '{{ .host }}:8080')
```

## Deploy with `score-k8s`

```bash
./scripts/setup-kind-cluster.sh

score-k8s init \
    --no-sample \
    --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/score-k8s/00-hpa.provisioners.yaml

score-k8s generate score.yaml \
    --image nginxinc/nginx-unprivileged:alpine-slim \
    --patch-manifests 'Deployment/*/spec.template.spec.securityContext={"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}' \
    --patch-manifests 'Deployment/*/spec.template.spec.serviceAccount=webapp'

echo '{"spec":{"template":{"spec":{"containers":[{"name":"webapp","securityContext":{"allowPrivilegeEscalation":false,"privileged": false,"readOnlyRootFilesystem": true,"capabilities":{"drop":["ALL"]}}}]}}}}' > deployment-patch.yaml
echo '{"apiVersion":"v1","kind":"ServiceAccount","metadata":{"name":"webapp"}}' | yq e -P > serviceaccount.yaml

NAMESPACE=default
kubectl apply -n $NAMESPACE -f manifests.yaml
kubectl patch -n $NAMESPACE deployment nginx --patch-file deployment-patch.yaml
kubectl apply -n $NAMESPACE -f serviceaccount.yaml

curl $(score-k8s resources get-outputs dns.default#nginx.dns --format '{{ .host }}')
```