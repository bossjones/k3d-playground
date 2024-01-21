install:
	helm install rancher rancher-latest/rancher \
	--namespace cattle-system \
	--create-namespace \
	--set ingress.enabled=false \
	--set tls=external \
	--set replicas=1
	kubectl -n cattle-system rollout status deploy/rancher
	kubectl -n cattle-system apply -f manifests/

uninstall:
	helm -n cattle-system uninstall rancher

reinstall: uninstall install
