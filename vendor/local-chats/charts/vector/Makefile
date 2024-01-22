render:
	helm template --version 0.30.0 --values vector-overrides.yaml vector vector/vector -n monitoring > vector_manifests.yaml

install:
	helm upgrade --install vector vector/vector -f vector-overrides.yaml -n monitoring --version 0.30.0

render-install: render install

proxy-grafana:
	kubectl port-forward service/monitoring-stack-grafana 8081:80 -n monitoring

uninstall:
	helm -n monitoring uninstall vector

reinstall: uninstall install
