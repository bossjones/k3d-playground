render:
	helm template --version 0.71.1 --values loki-distributed-overrides.yaml loki grafana/loki-distributed -n monitoring > loki_manifests.yaml

install-minio:
	kubectl create ns monitoring || true
	kubectl -n monitoring apply -f minio.yaml

install: install-minio
	kubectl create ns monitoring || true
	helm upgrade --version 0.71.1 --install --values loki-distributed-overrides.yaml loki grafana/loki-distributed -n monitoring

render-install: render install

uninstall:
	helm -n monitoring uninstall loki || true
	kubectl -n monitoring delete -f minio.yaml

reinstall: uninstall install

proxy-grafana:
	kubectl port-forward service/monitoring-stack-grafana 8081:80 -n monitoring
