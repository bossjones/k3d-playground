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
