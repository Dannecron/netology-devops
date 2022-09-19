## Connect to ya cloud k8s

```shell
yc managed-kubernetes cluster \
get-credentials <идентификатор или имя кластера> \
--external
```

```shell
kubectl cluster-info
```

### gitlab-admin-service-account.yaml

create k8s service account

```shell
kubectl apply -f gitlab-admin-service-account.yaml
```

get account token

```shell
kubectl -n kube-system get secrets -o json | \
jq -r '.items[] | select(.metadata.name | startswith("gitlab-admin")) | .data.token' | \
base64 --decode
```

### values.yaml

В файле заменить `gitlabUrl`, `runnerRegistrationToken` из `CI/CD` на gitlab.

```shell
helm repo add gitlab https://charts.gitlab.io
```

```shell
helm install --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner
```

```shell
kubectl get pods -n default | grep gitlab-runner
```
