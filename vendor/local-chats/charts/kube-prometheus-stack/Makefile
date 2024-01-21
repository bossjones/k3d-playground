render:
	helm template --version 48.2.2 --values kube-prometheus-stack-overrides.yaml monitoring-stack prometheus-community/kube-prometheus-stack -n monitoring  > prometheus_manifests.yaml

install:
	kubectl apply -f namespace.yaml
	helm upgrade  --version 48.2.2 --install --values kube-prometheus-stack-overrides.yaml monitoring-stack prometheus-community/kube-prometheus-stack -n monitoring

proxy:
	kubectl port-forward service/monitoring-stack-grafana 8081:80 -n monitoring

render-install: render install

uninstall:
	helm -n monitoring uninstall monitoring-stack

reinstall: uninstall install
