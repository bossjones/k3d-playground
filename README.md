# k3d-playground
Just messing around with k3d

Linux and macOS script to create a k3d (k3s in docker) cluster for development
including:

- [Cert Manager](https://github.com/cert-manager/cert-manager) provision and manage TLS certificates in Kubernetes
- [Cilium](https://github.com/cilium/cilium) eBPF-based networking, security, and observability
- [Grafana](https://github.com/grafana/grafana) visualize metrics, logs, and traces
- [Ingress-NGINX](https://github.com/kubernetes/ingress-nginx) ingress controller for Kubernetes using NGINX
- [Kubernetes Dashboard](https://github.com/kubernetes/dashboard) general-purpose web UI for Kubernetes
- [Loki](https://github.com/grafana/loki) log aggregation system
- [MetalLB](https://github.com/metallb/metallb) network load-balancer implementation
- [OpenFaaS](https://github.com/openfaas/faas) serverless functions made simple
- [Prometheus](https://github.com/prometheus/prometheus) monitoring system and time series database
- [Audit2rbac](https://github.com/liggitt/audit2rbac) create proper rbac from audit logs

## Requirements

A working `docker` installation is required. Additional tooling will be downloaded automatically if they are not
available: `helm`, `k3d` and `kubectl`.

### macOS notes

Docker Desktop for Mac does not support routing to containers by IP address meaning that cluster nodes and load balancer
addresses cannot be accessed directly. This functionality is supported natively by Linux and requires additional tooling
on macOS. One such utility is [docker-mac-net-connect](https://github.com/chipmk/docker-mac-net-connect) which can be
installed via [homebrew](https://brew.sh/):

```sh
brew install chipmk/tap/docker-mac-net-connect
brew services start chipmk/tap/docker-mac-net-connect
```



### Example traefik labels

```
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.minio-http.rule=Host(`minio.scarlettlab.home`)"
      - "traefik.http.routers.minio-http.entrypoints=web"
      - "traefik.http.routers.minio-http.service=minio-http"
      - "traefik.http.services.minio-http.loadbalancer.server.port=9000"
      - "traefik.port=9000"
```


```
# SOURCE: https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart
# dashboard.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.localhost`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
```


# Query to use when you get to grafana

```
{job="vector"} | json | line_format "{{.message}}" |= ``
```



## Resources versioning

```bash
- Kubernetes Version: v1.27.4-k3s1
- ArgoCD Version: v2.8.0
- k3d tested using v5.6 with v1alpha5 config file
```
### Avaliable Kubernetes services:

> - [ArgoCD][argocd-url] as the main GitOps tool | **Available at [argocd.k8s.localhost][argocd-localhost]**
> - Access to the cluster using [Nginx Ingress][nginx-url].
> - On-demand databases clusters with [Zalando Operator for PostgreSQL][postgres-url] | **UI available at [dbs.k8s.localhost][dbs-localhost]**
> - Hot-Reload secrets and configmaps to pods using [Reloader][reloader-url].
> - Mirror resources between namespaces using [Reflector][reflector-url].

### Tools required locally

> - [k3d][k3d-url] running atop of either (pick one):
>   - [Rancher Desktop **(Recommended)**][rancher-url]
>   - [Docker for Desktop][docker-url]
>   - [Podman][podman-url] (works but [requires extra steps][podman-steps])
> - [Task][task-url] as a more modern iteration of the Makefile utility
> - [mkcert][mkcert-url] for creating locally based TLS certificates for your ingress proxy
> - [kubectl][kubectl-url] | [kustomize][kustomize-url] | [helm][helm-url] to apply local commands to the cluster
> - [jq][jq-url] to manipulate the resulting JSON files and extract the required strings
> - [hostctl][hostctl-url] to create the local domain on your hosts file *(optional, but recommended)*

### In case you want to reset the environment

Whenever you want to restart from scratch and create a new cluster, just type `task` again.

<!---
> - Metrics monitoring with [Prometheus's Stack][prometheus-url] (Also includes [Grafana][grafana-url])
-->
<!--- References --->
[tls-uri]: https://github.com/gruberdev/local-gitops/tree/main/config/tls
[storage-uri]: https://github.com/gruberdev/local-gitops/tree/main/storage
[argocd-url]: https://argo-cd.readthedocs.io/en/stable/
[nginx-url]: https://github.com/kubernetes/ingress-nginx
[vault-url]: https://github.com/hashicorp/vault
[vault-plugin-url]: https://github.com/argoproj-labs/argocd-vault-plugin
[postgres-url]: https://github.com/zalando/postgres-operator
[reloader-url]: https://github.com/stakater/Reloader
[prometheus-url]: https://github.com/prometheus-operator/kube-prometheus
[grafana-url]: https://github.com/grafana/grafana
[kube-cleanup-url]: https://github.com/lwolf/kube-cleanup-operator
[reflector-url]: https://github.com/emberstack/kubernetes-reflector
[kubefledged-url]: https://github.com/senthilrch/kube-fledged
[descheduler-url]: https://github.com/kubernetes-sigs/descheduler
[kwatch-url]: https://github.com/abahmed/kwatch
[botkube-url]: https://github.com/infracloudio/botkube
[kubenurse-url]: https://github.com/postfinance/kubenurse
[longhorn-url]: https://longhorn.io/
[longhorn-issue]: https://github.com/rancher/k3d/discussions/478
[velero-url]: https://velero.io/
[velero-list-url]: https://velero.io/docs/v1.7/supported-providers/
[kube-dump-url]: https://github.com/WoozyMasta/kube-dump
[stash-url]: https://stash.run/
[task-url]: https://taskfile.dev
[task-installation-url]: https://taskfile.dev/installation/
[mkcert-url]: https://github.com/FiloSottile/mkcert
[kubectl-url]: https://kubernetes.io/docs/tasks/tools/
[jq-url]: https://stedolan.github.io/jq/download/
[k3d-url]: https://k3d.io
[docker-url]: https://www.docker.com/products/docker-desktop/
[rancher-url]: https://rancherdesktop.io/
[podman-url]: https://podman.io/
[podman-steps]: https://k3d.io/v5.6.0/usage/advanced/podman/
[hostctl-url]: https://github.com/guumaster/hostctl
[kustomize-url]: https://kubectl.docs.kubernetes.io/installation/kustomize/
[helm-url]: https://helm.sh/docs/intro/install/
[chocolate-url]: https://chocolatey.org/install
[brew-url]: https://brew.sh/

<!--- Local URIs --->
[argocd-localhost]: https://argocd.k8s.localhost
[vault-localhost]: https://vault.k8s.localhost
[dbs-localhost]: https://dbs.k8s.localhost
