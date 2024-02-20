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
- [gitea](https://gitea.com) Self-hosted Git service
- [Kanidm](https://kanidm.com) Modern and simple identity management platform
- [ntfy](https://ntfy.sh) Notification service to send notifications to your phone or desktop
- [Renovate](https://www.whitesourcesoftware.com/free-developer-tools/renovate) Automatically update dependencies
- [Woodpecker CI](https://woodpecker-ci.org) Simple yet powerful CI/CD engine with great extensibility
- [Gatus](https://gatus.io/) The automated status page that you deserve. If your infrastructure went down right now, how long would it take for you to know? (see https://github.com/onedr0p/home-ops/blob/main/kubernetes/main/apps/observability/gatus/app/helmrelease.yaml)
- node-feature-discovery
- [synology-csi](https://github.com/SynologyOpenSource/synology-csi): The official Container Storage Interface driver for Synology NAS. (https://github.com/JefeDavis/k8s-HomeOps/blob/main/README.md?plain=1)
- [sops](https://toolkit.fluxcd.io/guides/mozilla-sops/): Managed secrets for Kubernetes, Ansible and Terraform which are commited to Git.
- [system-upgrade-controller](https://github.com/rancher/system-upgrade-controller) Automatically updates kubernetes based off of a plan.
- [actions-runner-controller](https://github.com/actions/actions-runner-controller): Self-hosted Github runners.
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records for my cluster.
- [metallb](https://metallb.universe.tf/): Bare-Metal Load-balancer
- [Goldilocks](https://github.com/billimek/k8s-gitops/tree/8f5ff27df2673dbf442c3eee429f51b3b9b15256/default): Goldilocks: An Open Source Tool for Recommending Resource Requests
- [coredns](https://coredns.github.io/helm): also see https://github.com/billimek/k8s-gitops/blob/master/networking/coredns/coredns.yaml

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
- ArgoCD Version: v2.8.9
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


# k3d-pv.yaml and k3d-pvc.yaml

```
# SOURCE: https://blogops.mixinet.net/posts/k8s_static_content_server/
apiVersion: v1
kind: PersistentVolume
metadata:
  name: scs-pv
  labels:
    app.kubernetes.io/name: scs
spec:
  capacity:
    storage: 8Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  claimRef:
    name: scs-pvc
  storageClassName: local-storage
  local:
    path: /volumes/scs-pv
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: node.kubernetes.io/instance-type
          operator: In
          values:
          - k3s
# The nodeAffinity section is required but in practice the current definition selects all k3d nodes.
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: scs-pvc
  labels:
    app.kubernetes.io/name: scs
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: local-storage
```


# :cloud: Cloud services

While most of my infrastructure and workloads are selfhosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

The alternative solution to these two problems would be to host a Kubernetes cluster in the cloud and deploy applications like [HCVault](https://www.vaultproject.io/), [Vaultwarden](https://github.com/dani-garcia/vaultwarden), [ntfy](https://ntfy.sh/), and [Authentik](https://https://goauthentik.io/). However, maintaining another cluster and monitoring another group of workloads is a lot more time and effort than I am willing to put in and only saves me roughly $10/month.

| Service                                      | Use                                                            | Cost          |
| -------------------------------------------- | -------------------------------------------------------------- | ------------- |
| [GitHub](https://github.com/)                | Hosting this repository and continuous integration/deployments | Free          |
| [Auth0](https://auth0.com/)                  | Identity management and authentication                         | Free          |
| [Cloudflare](https://www.cloudflare.com/)    | Domain, DNS and proxy management                               | Free          |
| [1Password](https://1password.com/)          | Secrets with [External Secrets](https://external-secrets.io/)  | ~$65/y        |
| [Terraform Cloud](https://www.terraform.io/) | Storing Terraform state                                        | Free          |
| [B2 Storage](https://www.backblaze.com/b2)   | Offsite application backups                                    | ~$5/m         |
| [Pushover](https://pushover.net/)            | Kubernetes Alerts and application notifications                | Free          |
|                                              |                                                                | Total: ~$10/m |
