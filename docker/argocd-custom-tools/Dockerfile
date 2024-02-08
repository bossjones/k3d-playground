#syntax=docker/dockerfile:1.3
ARG ARGO_CD_VERSION="v2.8.9"
# https://github.com/argoproj/argo-cd/blob/master/Dockerfile
ARG KSOPS_VERSION="v4.3.1"
ARG TARGETARCH="arm64"
# ENV TARGETARCH ${TARGETARCH:-amd64}
# ENV TARGETARCH=64


#--------------------------------------------#
#--------Build Custom Argo Image-------------#
#--------------------------------------------#

# quay.io/argoproj/argocd:v2.7.0
FROM quay.io/argoproj/argocd:$ARGO_CD_VERSION as base

# Switch to root for the ability to perform install
USER root

ENV KUBERNETES_VERSION 1.27.4
# RUN apt-get update && apt-get install -y age

RUN apt-get --yes update && \
  apt-get --yes install curl gcc g++ git golang-go make openssl xz-utils unzip jsonnet jq wget pass gnupg


FROM base as kubeconform
# install Kubeval for validating Kubernetes YAML or JSON configuration files
ENV KUBECONFORM_VERSION 0.6.4
RUN curl -Lo /srv/kubeconform-v${KUBECONFORM_VERSION}-linux-amd64.tar.gz https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz && \
  tar -xf /srv/kubeconform-v${KUBECONFORM_VERSION}-linux-amd64.tar.gz -C /srv && \
  rm /srv/kubeconform-v${KUBECONFORM_VERSION}-linux-amd64.tar.gz && \
  mv /srv/kubeconform /kubeconform

FROM base as kubectl
# install kubectl to interact with Kubernetes
RUN curl -Lo /kubectl-${KUBERNETES_VERSION} https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x /kubectl-${KUBERNETES_VERSION}


FROM base as vault-cli
ENV VAULT_VERSION 1.12.0
RUN curl -Lo - https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip | funzip > /usr/local/bin/vault && \
  chmod +x /usr/local/bin/vault

FROM base as helm
ENV HELM_VERSION v3.10.2
RUN curl -Lo /srv/helm-${HELM_VERSION}-linux-amd64.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
  tar -xf /srv/helm-${HELM_VERSION}-linux-amd64.tar.gz -C /srv && \
  rm -f /srv/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
  mv /srv/linux-amd64/helm /helm

FROM base as konstraint
ENV KONSTRAINT_VERSION v0.30.0
RUN curl -Lo /srv/konstraint https://github.com/plexsystems/konstraint/releases/download/${KONSTRAINT_VERSION}/konstraint-linux-amd64 && \
    chmod +x /srv/konstraint && \
    mv /srv/konstraint /konstraint

FROM base as kubelogin
ENV KUBELOGIN_VERSION v0.0.29
RUN curl -Lo - https://github.com/Azure/kubelogin/releases/download/${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip | funzip > /kubelogin && \
  chmod +x /kubelogin

FROM base as sops
ENV SOPS_VERSION 3.8.1
RUN curl -LO https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 && \
  mv sops-v${SOPS_VERSION}.linux.amd64 /usr/local/bin/sops && \
  chmod +x /usr/local/bin/sops

FROM base as sopssecretgenerator
RUN set -x; VERSION=1.6.0 PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')" ARCH="arm64" && \
    wget -O /srv/SopsSecretGenerator https://github.com/goabout/kustomize-sopssecretgenerator/releases/download/v${VERSION}/SopsSecretGenerator_${VERSION}_${PLATFORM}_${ARCH} && \
    chown argocd:argocd /srv/SopsSecretGenerator && \
    chmod +x /srv/SopsSecretGenerator && \
    mv /srv/SopsSecretGenerator /SopsSecretGenerator

###########
FROM base as age
ENV AGE_VERSION 1.1.1
# RUN set -eux; \
#     mkdir -p /usr/src/age/; \
#     wget -O /usr/src/age/age-v${AGE_VERSION}-linux-amd64.tar.gz -q "https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz"; \
#     tar x -zf age-v${AGE_VERSION}-linux-amd64.tar.gz --strip-components=1; \
#     cp age /usr/local/bin/age; \
#     cp age-keygen /usr/local/bin/age-keygen; \
#     chown root.root /usr/local/bin/age*; \
#     chmod 0755 /usr/local/bin/age*; \
#     mv /usr/src/age /age; \
#     /usr/local/bin/age --version
RUN set -eux; \
    curl -Lo /srv/age-v${AGE_VERSION}-linux-amd64.tar.gz https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz && \
    tar -xf /srv/age-v${AGE_VERSION}-linux-amd64.tar.gz -C /srv && \
    rm /srv/age-v${AGE_VERSION}-linux-amd64.tar.gz && \
    mv /srv/age /age

#--------------------------------------------#
#--------Build KSOPS and Kustomize-----------#
#--------------------------------------------#

FROM viaductoss/ksops:$KSOPS_VERSION as ksops-builder

FROM base
COPY --from=kubectl /kubectl-${KUBERNETES_VERSION} /usr/local/bin/kubectl-${KUBERNETES_VERSION}
COPY --from=kubeconform /kubeconform /usr/local/bin/kubeconform
COPY --from=prom/prometheus:v2.30.3 /bin/promtool /usr/local/bin/promtool
RUN ln -s /usr/local/bin/kubectl-${KUBERNETES_VERSION} /usr/local/bin/kubectl-1.23 && \
  chmod +x /usr/local/bin/kubectl-${KUBERNETES_VERSION} && \
  ln -s /usr/local/bin/kubectl-1.23 /usr/local/bin/kubectl-latest && \
  ln -s /usr/local/bin/kubectl-latest /usr/local/bin/kubectl
COPY --from=vault-cli /usr/local/bin/vault /usr/local/bin/vault
COPY --from=helm /helm /usr/local/bin/helm
# COPY --from=virtualenv /.venv /.venv
# COPY --from=crane /srv/crane /usr/local/bin/crane
COPY --from=konstraint /konstraint /usr/local/bin/konstraint
# COPY --from=conftest /srv/conftest /usr/local/bin/conftest
# COPY --from=argocd /argocd /usr/local/bin/argocd
COPY --from=age /age /usr/local/bin/age
COPY --from=age /age /usr/local/bin/age-keygen
COPY --from=sopssecretgenerator --chown=argocd /SopsSecretGenerator /usr/local/bin/SopsSecretGenerator



ARG PKG_NAME=ksops

# Override the default kustomize executable with the Go built version
COPY --from=ksops-builder --chown=argocd /usr/local/bin/kustomize /usr/local/bin/kustomize

# Add ksops executable to path
COPY --from=ksops-builder --chown=argocd /usr/local/bin/ksops /usr/local/bin/ksops
COPY --from=sops --chown=argocd /usr/local/bin/sops /usr/local/bin/sops

ENV MAIN_PATH=/custom-tools
ENV HELM_SECRETS_VERSION=4.4.2
ENV VALS_VERSION=0.24.0
ENV KUBECTL_VERSION=${KUBERNETES_VERSION}
ENV SOPS_VERSION 3.8.1

RUN mkdir -p $MAIN_PATH/helm-plugins
RUN wget -qO- https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/helm-secrets.tar.gz | tar -C $MAIN_PATH/helm-plugins -xzf-;
RUN wget -qO $MAIN_PATH/sops https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64
# COPY --from=sops /usr/local/bin/sops /custom-tools/sops
RUN wget -qO $MAIN_PATH/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN wget -qO- https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_amd64.tar.gz | tar -xzf- -C $MAIN_PATH/ vals;
RUN wget -qO $MAIN_PATH/curl https://github.com/moparisthebest/static-curl/releases/latest/download/curl-amd64
RUN cp $MAIN_PATH/helm-plugins/helm-secrets/scripts/wrapper/helm.sh $MAIN_PATH/helm
RUN cp -a /usr/local/bin/kustomize $MAIN_PATH/kustomize
RUN chmod +x $MAIN_PATH/*

# Switch back to non-root user
USER argocd


# SOURCE: https://github.com/aggregion/argo-base/blob/master/install/helm-secrets/helm-secrets.dockerfile
# FROM alpine:latest

# ENV MAIN_PATH=/custom-tools
# ENV HELM_SECRETS_VERSION=4.4.2
# ENV KUBECTL_VERSION=1.26.1
# ENV VALS_VERSION=0.24.0
# ENV SOPS_VERSION=3.8.1

# RUN mkdir -p $MAIN_PATH/helm-plugins
# RUN wget -qO- https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/helm-secrets.tar.gz | tar -C $MAIN_PATH/helm-plugins -xzf-;
# RUN wget -qO $MAIN_PATH/sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux
# RUN wget -qO $MAIN_PATH/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
# RUN wget -qO- https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_amd64.tar.gz | tar -xzf- -C $MAIN_PATH/ vals;
# RUN cp $MAIN_PATH/helm-plugins/helm-secrets/scripts/wrapper/helm.sh $MAIN_PATH/helm
# RUN chmod +x $MAIN_PATH/*
