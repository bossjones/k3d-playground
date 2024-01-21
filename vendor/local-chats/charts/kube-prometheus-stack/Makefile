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
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheusagents.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd scrapeconfigs.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com

reinstall: uninstall install
