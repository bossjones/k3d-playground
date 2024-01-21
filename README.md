# k3d-playground
Just messing around with k3d


### Example traefik labels

```
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.minio-http.rule=Host(`minio.scarlettlab.home`)"
      - "traefik.http.routers.minio-http.entrypoints=web"
      - "traefik.http.routers.minio-http.service=minio-http"
      - "traefik.http.services.minio-http.loadbalancer.server.port=9000"
      - "traefik.port=9000"
```


```
# SOURCE: https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart
# dashboard.yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.localhost`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
```
