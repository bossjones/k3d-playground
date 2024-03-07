#!/usr/bin/env bash
# set -euxo pipefail
set -x


cluster_name="demo"
context="k3d-${cluster_name}"

  kubectl create namespace monitoring || true
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
  kubectl -n monitoring apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.71.2/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
  kubectl -n kube-system apply --server-side -f https://raw.githubusercontent.com/external-secrets/external-secrets/v0.9.11/deploy/crds/bundle.yaml || true


helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo update
helm template --version 4.9.0 --values apps/argocd/base/core/ingress-nginx/app/values.yaml ingress-nginx ingress-nginx/ingress-nginx -n kube-system | kubectl apply --server-side -f -

echo "waiting for ingress-nginx deployment.apps/ingress-nginx-controller"
kubectl -n kube-system wait deployment ingress-nginx-controller --for condition=Available=True --timeout=300s

# detect ingress-nginx service ip address
lb_ip=$(kubectl -n kube-system get svc/ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')


# default proxy_host to sslip magic domain
# sslip_prefix="k3s-$(echo demo | sed -E 's/([0-9])$/\1-/')"
if [[ "$proxy_host" == "" ]]; then
  proxy_host="k8s.localhost"
fi


# -p, --proxy-http-port <>     ingress http port to expose on host (default: ${default_proxy_http_port:-none})
# -t, --proxy-tls-port <>      ingress tls port to expose on host (default: ${default_proxy_tls_port:-none})
default_proxy_http_port=8080
proxy_http_port="80"
params+=( proxy_http_port )

default_proxy_tls_port=8443
proxy_tls_port="443"
params+=( proxy_tls_port )

# create proxy to access ingress load balancer service
declare -a proxy_args=()
[[ "$proxy_http_port" == "" ]] || proxy_args+=( -p "$proxy_http_port:80" )
[[ "$proxy_tls_port"  == "" ]] || proxy_args+=( -p "$proxy_tls_port:443" )
proxy_args+=( --env "INGRESS_HOST=$lb_ip" )

if [[ "$proxy_protocol" == "true" ]]; then
  if [[ "$proxy_no_labels" == "false" ]]; then
    proxy_args+=( --label "traefik.enable=true" )
    proxy_args+=( --label "traefik.tcp.routers.$proxy_service.rule=HostSNIRegexp(\`$proxy_host\`, \`{subdomain:[a-z0-9_-]+}.$proxy_host\`)" )
    proxy_args+=( --label "traefik.tcp.routers.$proxy_service.entryPoints=$proxy_entrypoint" )
    proxy_args+=( --label "traefik.tcp.routers.$proxy_service.tls.passthrough=true" )
    proxy_args+=( --label "traefik.tcp.services.$proxy_service.loadBalancer.proxyProtocol.version=2" )
    proxy_args+=( --label "traefik.tcp.services.$proxy_service.loadBalancer.server.port=443" )
  fi
  nginx_conf_listen_extra="proxy_protocol"
  nginx_conf_server_extra="
    proxy_protocol on;
    set_real_ip_from 10.0.0.0/8;
    set_real_ip_from 172.16.0.0/12;
    set_real_ip_from 192.168.0.0/16;"
else
  if [[ "$proxy_no_labels" == "false" ]]; then
    proxy_args+=( --label "traefik.enable=true" )
    proxy_args+=( --label "traefik.http.routers.$proxy_service.rule=HostRegexp(\`$proxy_host\`, \`{subdomain:[a-z0-9_-]+}.$proxy_host\`)" )
    proxy_args+=( --label "traefik.http.routers.$proxy_service.entryPoints=$proxy_entrypoint" )
    proxy_args+=( --label "traefik.http.routers.$proxy_service.tls.certResolver=$proxy_certresolver" )
    proxy_args+=( --label "traefik.http.routers.$proxy_service.tls.domains[0].main=$proxy_host" )
    proxy_args+=( --label "traefik.http.routers.$proxy_service.tls.domains[0].sans=*.$proxy_host" )
    proxy_args+=( --label "traefik.http.services.$proxy_service.loadBalancer.server.port=443" )
    proxy_args+=( --label "traefik.http.services.$proxy_service.loadBalancer.server.scheme=https" )
  fi
  nginx_conf_listen_extra=""
  nginx_conf_server_extra=""
fi

declare -a proxy_command=( bash -c "$(cat <<ESH
cat <<EOF >/etc/nginx/nginx.conf
error_log stderr notice;
worker_processes auto;

events {
  multi_accept on;
  use epoll;
  worker_connections 4096;
}

stream {
  upstream 80_tcp {
    server \${INGRESS_HOST}:80;
  }

  server {
    listen 80${nginx_conf_listen_extra};
    proxy_pass 80_tcp;${nginx_conf_server_extra}
  }

  upstream 443_tcp {
    server \${INGRESS_HOST}:443;
  }

  server {
    listen 443${nginx_conf_listen_extra:+ $nginx_conf_listen_extra};
    proxy_pass 443_tcp;${nginx_conf_server_extra}
  }
}
EOF
nginx -g 'daemon off;'
ESH
    )" )

proxy_name="${context}-proxy"
docker rm -f "$proxy_name" 2>/dev/null || true
docker create --name "$proxy_name" --restart=always --network=demo-net "${proxy_args[@]}" nginx "${proxy_command[@]}"
docker start "$proxy_name"

# determine host ip address
host_ip=$(ifconfig | perl -0777 -pe 's/\n+^[ \t]/ /gm' | grep 'inet ' | grep RUNNING | grep -v LOOPBACK \
  | sed -nE 's/.* inet ([^ ]+).*/\1/p' | grep -vE '\.1$')

host_domain="k8s.localhost"
