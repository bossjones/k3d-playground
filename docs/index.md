# Home Cluster

This repository _is_ my home Kubernetes cluster in a declarative state. [ArgoCD](https://github.com/argoproj/argo-cd/) watches my repo and makes the changes to my cluster based on the YAML manifests.

Feel free to open a [Github issue](https://github.com/bossjones/k3d-playground/issues/new/choose) if you have any questions.


## Cluster setup

My cluster is [k3d](https://k3d.io/) provisioned overtop either MacOS with Docker Desktop or Proxmox VM running Ubuntu 22.04 This is a work in progress.

## Cluster components

- [metallb](https://metallb.universe.tf/): For internal cluster networking using BGP.
- [cert-manager](https://cert-manager.io/docs/): Configured to create TLS certs for all ingress services automatically using LetsEncrypt.
- [ingress-nginx](https://kubernetes.github.io/ingress-nginx/): My preferred ingress controller to expose traffic to pods over DNS.
- [vault](https://www.vaultproject.io/): Hashicorp Vault to Manage Secrets & Protect Sensitive Data and internal self-signed TLS certs


## Automate all the things!

- [Github Actions](https://docs.github.com/en/actions) for checking code formatting
- Rancher [System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) to apply updates to k3s
- [Renovate](https://github.com/renovatebot/renovate) with the help of the [k8s-at-home/renovate-helm-releases](https://github.com/k8s-at-home/renovate-helm-releases) Github action keeps my application charts and container images up-to-date


## Tools

| Tool                                                   | Purpose                                                   |
|--------------------------------------------------------|-----------------------------------------------------------|
| [k9s](https://github.com/derailed/k9s)                 | Kubernetes CLI To Manage Your Cluster                     |
| [pre-commit](https://github.com/pre-commit/pre-commit) | Enforce code consistency and verifies no secrets are pushed |
| [stern](https://github.com/stern/stern)                | Tail logs in Kubernetes                                   |

## Thanks

A lot of inspiration for this repo came from [billimek/git-ops](https://github.com/billimek/k3d-playground) and the people that have shared their clusters over at [awesome-home-kubernetes](https://github.com/k8s-at-home/awesome-home-kubernetes)
