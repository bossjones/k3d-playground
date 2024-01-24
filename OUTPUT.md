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

# rancher

```
pi@boss-station ~/dev/bossjones/k3d-playground/vendor/local-chats/charts/rancher main
❯ make install
helm install rancher rancher-latest/rancher \
--namespace cattle-system \
--create-namespace \
--set ingress.enabled=false \
--set tls=external \
--set replicas=1
NAME: rancher
LAST DEPLOYED: Sun Jan 21 14:04:25 2024
NAMESPACE: cattle-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Rancher Server has been installed.

NOTE: Rancher may take several minutes to fully initialize. Please standby while Certificates are being issued, Containers are started and the Ingress rule comes up.

Check out our docs at https://rancher.com/docs/

If you provided your own bootstrap password during installation, browse to https:// to get started.

If this is the first time you installed Rancher, get started by running this command and clicking the URL it generates:

```
echo https:///dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
```

To get just the bootstrap password on its own, run:

```
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}'
```


Happy Containering!
kubectl -n cattle-system rollout status deploy/rancher
Waiting for deployment "rancher" rollout to finish: 0 of 1 updated replicas are available...
deployment "rancher" successfully rolled out
kubectl -n cattle-system aply -f manifests/
Error: flags cannot be placed before plugin name: -n
make: *** [Makefile:4: install] Error 1

pi@boss-station ~/dev/bossjones/k3d-playground/vendor/local-chats/charts/rancher main 2m 36s
❯ kubectl -n cattle-system apply -f manifests/
Found existing alias for "kubectl". You should use: "k"


```

# portainer

```
pi@boss-station ~/dev/bossjones/k3d-playground main
❯ just portainer-install
helm repo add portainer https://portainer.github.io/k8s/
"portainer" has been added to your repositories
helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "kubernetes-dashboard" chart repository
...Successfully got an update from the "portainer" chart repository
...Successfully got an update from the "influxdata" chart repository
...Successfully got an update from the "rancher-latest" chart repository
...Successfully got an update from the "grafana" chart repository
...Successfully got an update from the "prometheus-community" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈Happy Helming!⎈
helm upgrade --install --create-namespace -n portainer portainer portainer/portainer --set tls.force=false
Release "portainer" does not exist. Installing it now.
NAME: portainer
LAST DEPLOYED: Sun Jan 21 18:16:15 2024
NAMESPACE: portainer
STATUS: deployed
REVISION: 1
NOTES:
Get the application URL by running these commands:
    export NODE_PORT=$(kubectl get --namespace portainer -o jsonpath="{.spec.ports[1].nodePort}" services portainer)
  export NODE_IP=$(kubectl get nodes --namespace portainer -o jsonpath="{.items[0].status.addresses[0].address}")
  echo https://$NODE_IP:$NODE_PORT
echo "open: https://localhost:30779/ or http://localhost:30777/ to access portainer"
open: https://localhost:30779/ or http://localhost:30777/ to access portainer

```


#####################################

```
~/dev/bossjones/k3d-playground main* 57s
❯  sudo brew services start chipmk/tap/docker-mac-net-connect
Password:
Warning: Taking root:admin ownership of some docker-mac-net-connect paths:
  /opt/homebrew/Cellar/docker-mac-net-connect/v0.1.2/bin
  /opt/homebrew/Cellar/docker-mac-net-connect/v0.1.2/bin/docker-mac-net-connect
  /opt/homebrew/opt/docker-mac-net-connect
  /opt/homebrew/opt/docker-mac-net-connect/bin
  /opt/homebrew/var/homebrew/linked/docker-mac-net-connect
This will require manual removal of these paths using `sudo rm` on
brew upgrade/reinstall/uninstall.
Warning: docker-mac-net-connect must be run as non-root to start at user login!
==> Successfully started `docker-mac-net-connect` (label: homebrew.mxcl.docker-mac-net-connect)

~/dev/bossjones/k3d-playground main* 9s
❯

```
