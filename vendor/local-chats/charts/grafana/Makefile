render:
	helm template --version 6.58.6 --values grafana-overrides.yaml grafana grafana/grafana -n grafana > grafana_manifests.yaml

install-minio:
	kubectl -n grafana apply -f minio.yaml

# helm upgrade [RELEASE] [CHART] [flags]
install:
	helm upgrade --version 6.58.6 --install --values grafana-overrides.yaml grafana grafana/grafana -n grafana

render-install: render install

uninstall:
	helm -n grafana uninstall grafana

reinstall: uninstall install

proxy-grafana:
	kubectl port-forward service/monitoring-stack-grafana 8081:80 -n monitoring
