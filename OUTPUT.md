# nodes
```
pi@boss-station ~/dev/bossjones/Users/malcolm/dev/prometheus-community/helm-charts/charts/kube-prometheus-stack main* ⇣ 43s
❯ kubectl get nodes
Found existing alias for "kubectl". You should use: "k"
NAME                          STATUS   ROLES                  AGE     VERSION
k3d-k3d-playground-agent-1    Ready    <none>                 2d18h   v1.29.0+k3s1
k3d-k3d-playground-agent-0    Ready    <none>                 2d18h   v1.29.0+k3s1
k3d-k3d-playground-server-0   Ready    control-plane,master   2d18h   v1.29.0+k3s1

```

# grafana
```
pi@boss-station ~/dev/bossjones/Users/malcolm/dev/grafana/helm-charts/charts/grafana main* 10s
❯ make install
helm upgrade --install --create-namespace --values grafana-overrides.yaml grafana grafana/grafana -n grafana
Release "grafana" does not exist. Installing it now.
coalesce.go:220: warning: cannot overwrite table with non table for grafana.testFramework.image (map[registry:docker.io repository:bats/bats tag:v1.4.1])
NAME: grafana
LAST DEPLOYED: Sun Jan 21 10:45:15 2024
NAMESPACE: grafana
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.grafana.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
     export POD_NAME=$(kubectl get pods --namespace grafana -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace grafana port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Grafana pod is terminated.                            #####
#################################################################################

pi@boss-station ~/dev/bossjones/Users/malcolm/dev/grafana/helm-charts/charts/grafana main*
❯

```


# kube-prometheus-stack

```
pi@boss-station ~/dev/bossjones/Users/malcolm/dev/prometheus-community/helm-charts/charts/kube-prometheus-stack main* ⇣
❯ make install
kubectl apply -f namespace.yaml
namespace/monitoring created
helm upgrade --install --values kube-prometheus-stack-overrides.yaml monitoring-stack prometheus-community/kube-prometheus-stack -n monitoring
Release "monitoring-stack" does not exist. Installing it now.
W0121 10:48:30.883788 1376574 warnings.go:70] unknown field "spec.ruleNamespaceSelector.any"
NAME: monitoring-stack
LAST DEPLOYED: Sun Jan 21 10:48:07 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=monitoring-stack"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

pi@boss-station ~/dev/bossjones/Users/malcolm/dev/prometheus-community/helm-charts/charts/kube-prometheus-stack main* ⇣ 43s

```

# loki-distributed

```
pi@boss-station ~/dev/bossjones/Users/malcolm/dev/grafana/helm-charts/charts/loki-distributed main*
❯ make install
kubectl -n monitoring apply -f minio.yaml
secret/my-minio-cred created
service/minio created
deployment.apps/minio created
helm upgrade --install --values loki-distributed-overrides.yaml loki grafana/loki-distributed -n monitoring
Release "loki" does not exist. Installing it now.
NAME: loki
LAST DEPLOYED: Sun Jan 21 11:19:46 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
***********************************************************************
 Welcome to Grafana Loki
 Chart version: 0.78.1
 Loki version: 2.9.2
***********************************************************************

Installed components:
* gateway
* ingester
* distributor
* querier
* query-frontend

pi@boss-station ~/dev/bossjones/Users/malcolm/dev/grafana/helm-charts/charts/loki-distributed main*
❯

```
