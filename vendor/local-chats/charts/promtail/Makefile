render:
	helm template --version 6.11.9 --values promtail-overrides.yaml promtail grafana/promtail -n monitoring > promtail_manifests.yaml

install:
	helm upgrade --version 6.11.9 --install --values promtail-overrides.yaml promtail grafana/promtail -n monitoring

render-install: render install

proxy-grafana:
	kubectl port-forward service/monitoring-stack-grafana 8081:80 -n monitoring

uninstall:
	helm -n monitoring uninstall promtail

reinstall: uninstall install
