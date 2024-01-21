render:
	helm template --values memcached-overrides.yaml memcached bitnamicharts/memcached -n monitoring > memcached_manifests.yaml

install-minio:
	kubectl -n monitoring apply -f minio.yaml

install: install-minio
	helm upgrade --install --values memcached-overrides.yaml memcached bitnamicharts/memcached -n monitoring

render-install: render install

uninstall:
	helm -n monitoring uninstall memcached
