install:
	helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set ingress.enabled=false \
  --set tls=external \
  --set replicas=1

uninstall:
	helm -n cattle-system uninstall rancher

reinstall: uninstall install
