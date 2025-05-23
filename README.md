# nginx-score-demo

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/mathieu-benoit/nginx-score-demo)

A Developer authors and maintains their files in the [`website`](./website/) folder, their [`Dockerfile`](Dockerfile) and the [`score.yaml`](score.yaml) file.

Then, they can deploy their `score.yaml` file with three options:
- [Deploy with `score-compose`](#deploy-with-score-compose)
- [Deploy with `score-k8s`](#deploy-with-score-k8s)
- [Deploy with `humctl`](#deploy-with-humctl)

## Deploy with `score-compose`

Initialize the local `score-compose` workspace:
```bash
score-compose init \
    --no-sample \
    --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/horizontal-pod-autoscaler/score-compose/10-hpa.provisioners.yaml \
    --patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-compose/unprivileged.tpl
```

Generate the Docker Compose files:
```bash
score-compose generate score.yaml \
    --build 'webapp={"context":"."}'
```

Deploy the Docker Compose files:
```bash
docker compose up --build -d --remove-orphans
```

Test the deployed Workload:
```bash
curl $(score-compose resources get-outputs dns.default#nginx.dns --format '{{ .host }}:8080')
```

## Deploy with `score-k8s`

Prepare the cluster:
```bash
./scripts/setup-kind-cluster.sh

CONTAINER_IMAGE=nginx-score-demo-nginx-webapp:latest
kind load docker-image ${CONTAINER_IMAGE}

NAMESPACE=default
kubectl create ns $NAMESPACE
kubectl label ns $NAMESPACE pod-security.kubernetes.io/enforce=restricted
```

Initialize the local `score-k8s` workspace:
```bash
score-k8s init \
    --no-sample \
    --provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/horizontal-pod-autoscaler/score-k8s/10-hpa.provisioners.yaml \
    --patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/service-account.tpl \
    --patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-k8s/unprivileged.tpl
```

Generate the Kubernetes manifests:
```bash
score-k8s generate score.yaml \
    --image ${CONTAINER_IMAGE}
```

Deploy the Kubernetes manifests:
```bash
kubectl apply -n $NAMESPACE -f manifests.yaml
```

Test the deployed Workload:
```bash
curl $(score-k8s resources get-outputs dns.default#nginx.dns --format '{{ .host }}')
```

## Deploy with `humctl`

Deploy the Score file in Humanitec:
```bash
CONTAINER_IMAGE_IN_REGISTRY=FIXME

humctl score deploy -f score.yaml \
    --app ${APP} \
    --env ${ENV} \
    --image ${CONTAINER_IMAGE_IN_REGISTRY}
```

_Note: this is assuming that Platform Engineers have registered the following [`volume`](https://developer.humanitec.com/examples/resource-definitions?capability=volumes), [`horizontal-pod-autoscaler`](https://developer.humanitec.com/examples/resource-definitions?capability=horizontal-pod-autoscaler) and [`workload` with `securityContext`](https://developer.humanitec.com/examples/resource-definitions/template-driver/security-context/) in Humanitec._

Test the deployed Workload:
```bash
humctl get active-resources \
    --app ${APP} \
    --env ${ENV} \
    -o json \
    | jq -r '. | map(. | select(.metadata.type == "dns")) | map((.metadata.res_id | split(".") | .[1]) + ": [" + .status.resource.host + "](https://" + .status.resource.host + ")") | join("\n")'
```
