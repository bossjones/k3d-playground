render:
	helm template --version 0.30.0 --values vector-overrides.yaml vector vector/vector -n monitoring > vector_manifests.yaml

install:
	helm repo add deliveryhero https://charts.deliveryhero.io/ || true
	helm install k8s-event-logger deliveryhero/k8s-event-logger --version=1.1.4 || true
	helm upgrade --install vector vector/vector -f vector-overrides.yaml -n monitoring --version 0.30.0

render-install: render install

proxy-grafana:
	kubectl port-forward service/monitoring-stack-grafana 8081:80 -n monitoring

uninstall:
	helm -n monitoring uninstall vector

reinstall: uninstall install

monitor:
	kubectl -n monitoring exec -it statefulset/vector -- vector top --url http://0.0.0.0:8686/graphql

metrics: monitor
