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
