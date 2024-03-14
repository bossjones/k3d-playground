## Resources

- [What is the difference between Ingress and IngressRoute](https://community.traefik.io/t/what-is-the-difference-between-ingress-and-ingressroute/10864/10)
- https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/05-allow-traffic-from-all-namespaces.md
- https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/06-allow-traffic-from-a-namespace.md
- https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/master/08-allow-external-traffic.md
- [cilium k3d](https://github.com/chainguard-images/images/blob/27d4487ab413d583101d015a0bb610424f953d38/images/cilium/tests/cilium-install.sh)


```
# SOURCE: https://github.com/chainguard-images/images/blob/27d4487ab413d583101d015a0bb610424f953d38/images/cilium/tests/cilium-install.sh
# These settings come from
# https://docs.cilium.io/en/latest/installation/rancher-desktop/#configure-rancher-desktop
for node in $(kubectl get --context=k3d-$CLUSTER_NAME nodes -o jsonpath='{.items[*].metadata.name}'); do
    echo "Configuring mounts for $node"
    docker exec -i $node /bin/sh <<-EOF
        mount bpffs -t bpf /sys/fs/bpf
        mount --make-shared /sys/fs/bpf
        mkdir -p /run/cilium/cgroupv2
        mount -t cgroup2 none /run/cilium/cgroupv2
        mount --make-shared /run/cilium/cgroupv2/
EOF
done
```


### argocd configmap defaults

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cmd-params-cm
  labels:
    app.kubernetes.io/name: argocd-cmd-params-cm
    app.kubernetes.io/part-of: argocd
data:
  # Repo server address. (default "argocd-repo-server:8081")
  repo.server: "argocd-repo-server:8081"

  # Redis server hostname and port (e.g. argocd-redis:6379)
  redis.server: "argocd-redis:6379"
  # Enable compression for data sent to Redis with the required compression algorithm. (default 'gzip')
  redis.compression: gzip
  # Redis database
  redis.db:

  # Open-Telemetry collector address: (e.g. "otel-collector:4317")
  otlp.address: ""
  # Open-Telemetry collector insecure: (e.g. "true")
  otlp.insecure: "true"
  # Open-Telemetry collector headers: (e.g. "key1=value1,key2=value2")
  otlp.headers: ""

  # List of additional namespaces where applications may be created in and
  # reconciled from. The namespace where Argo CD is installed to will always
  # be allowed.
  #
  # Feature state: Beta
  application.namespaces: ns1, ns2, ns3

  ## Controller Properties
  # Repo server RPC call timeout seconds.
  controller.repo.server.timeout.seconds: "60"
  # Disable TLS on connections to repo server
  controller.repo.server.plaintext: "false"
  # Whether to use strict validation of the TLS cert presented by the repo server
  controller.repo.server.strict.tls: "false"
  # Number of application status processors (default 20)
  controller.status.processors: "20"
  # Number of application operation processors (default 10)
  controller.operation.processors: "10"
  # Set the logging format. One of: text|json (default "text")
  controller.log.format: "text"
  # Set the logging level. One of: debug|info|warn|error (default "info")
  controller.log.level: "info"
  # Prometheus metrics cache expiration (disabled  by default. e.g. 24h0m0s)
  controller.metrics.cache.expiration: "24h0m0s"
  # Specifies timeout between application self heal attempts (default 5)
  controller.self.heal.timeout.seconds: "5"
  # Cache expiration for app state (default 1h0m0s)
  controller.app.state.cache.expiration: "1h0m0s"
  # Specifies if resource health should be persisted in app CRD (default true)
  # Changing this to `false` significantly reduce number of Application CRD updates and improves controller performance.
  # However, disabling resource health by default might affect applications that communicate with Applications CRD directly
  # so we have to defer switching this to `false` by default till v3.0 release.
  controller.resource.health.persist: "true"
  # Cache expiration default (default 24h0m0s)
  controller.default.cache.expiration: "24h0m0s"
  # Sharding algorithm used to balance clusters accross application controller shards (default "legacy")
  controller.sharding.algorithm: legacy
  # Number of allowed concurrent kubectl fork/execs. Any value less than 1 means no limit.
  controller.kubectl.parallelism.limit: "20"
  # The maximum number of retries for each request
  controller.k8sclient.retry.max: "0"
  # The initial backoff delay on the first retry attempt in ms. Subsequent retries will double this backoff time up to a maximum threshold
  controller.k8sclient.retry.base.backoff: "100"
  # Grace period in seconds for ignoring consecutive errors while communicating with repo server.
  controller.repo.error.grace.period.seconds: "180"
  # Enables the server side diff feature at the application controller level.
  # Diff calculation will be done by running a server side apply dryrun (when
  # diff cache is unavailable).
  controller.diff.server.side: "false"

  ## Server properties
  # Listen on given address for incoming connections (default "0.0.0.0")
  server.listen.address: "0.0.0.0"
  # Listen on given address for metrics (default "0.0.0.0")
  server.metrics.listen.address: "0.0.0.0"
  # Run server without TLS
  server.insecure: "false"
  # Value for base href in index.html. Used if Argo CD is running behind reverse proxy under subpath different from / (default "/")
  server.basehref: "/"
  # Used if Argo CD is running behind reverse proxy under subpath different from /
  server.rootpath: ""
  # Directory path that contains additional static assets
  server.staticassets: "/shared/app"
  # The maximum number of retries for each request
  server.k8sclient.retry.max: "0"
  # The initial backoff delay on the first retry attempt in ms. Subsequent retries will double this backoff time up to a maximum threshold
  server.k8sclient.retry.base.backoff: "100"
  # Semicolon-separated list of content types allowed on non-GET requests. Set an empty string to allow all. Be aware
  # that allowing content types besides application/json may make your API more vulnerable to CSRF attacks.
  server.api.content.types: "application/json"

  # Set the logging format. One of: text|json (default "text")
  server.log.format: "text"
  # Set the logging level. One of: debug|info|warn|error (default "info")
  server.log.level: "info"
  # Repo server RPC call timeout seconds. (default 60)
  server.repo.server.timeout.seconds: "60"
  # Use a plaintext client (non-TLS) to connect to repository server
  server.repo.server.plaintext: "false"
  # Perform strict validation of TLS certificates when connecting to repo server
  server.repo.server.strict.tls: "false"
  # Dex server address (default "http://argocd-dex-server:5556")
  server.dex.server: "http://argocd-dex-server:5556"
  # Use a plaintext client (non-TLS) to connect to dex server
  server.dex.server.plaintext: "false"
  # Perform strict validation of TLS certificates when connecting to dex server
  server.dex.server.strict.tls: "false"
  # Disable client authentication
  server.disable.auth: "false"
  # Toggle GZIP compression
  server.enable.gzip: "true"
  # Set X-Frame-Options header in HTTP responses to value. To disable, set to "". (default "sameorigin")
  server.x.frame.options: "sameorigin"
  # The minimum SSL/TLS version that is acceptable (one of: 1.0|1.1|1.2|1.3) (default "1.2")
  server.tls.minversion: "1.2"
  # The maximum SSL/TLS version that is acceptable (one of: 1.0|1.1|1.2|1.3) (default "1.3")
  server.tls.maxversion: "1.3"
  # The list of acceptable ciphers to be used when establishing TLS connections. Use 'list' to list available ciphers. (default "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:TLS_RSA_WITH_AES_256_GCM_SHA384")
  server.tls.ciphers: "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:TLS_RSA_WITH_AES_256_GCM_SHA384"
  # Cache expiration for cluster/repo connection status (default 1h0m0s)
  server.connection.status.cache.expiration: "1h0m0s"
  # Cache expiration for OIDC state (default 3m0s)
  server.oidc.cache.expiration: "3m0s"
  # Cache expiration for failed login attempts (default 24h0m0s)
  server.login.attempts.expiration: "24h0m0s"
  # Cache expiration for app state (default 1h0m0s)
  server.app.state.cache.expiration: "1h0m0s"
  # Cache expiration default (default 24h0m0s)
  server.default.cache.expiration: "24h0m0s"
  # Enable the experimental proxy extension feature
  server.enable.proxy.extension: "false"

  ## Repo-server properties
  # Listen on given address for incoming connections (default "0.0.0.0")
  reposerver.listen.address: "0.0.0.0"
  # Listen on given address for metrics (default "0.0.0.0")
  reposerver.metrics.listen.address: "0.0.0.0"
  # Set the logging format. One of: text|json (default "text")
  reposerver.log.format: "text"
  # Set the logging level. One of: debug|info|warn|error (default "info")
  reposerver.log.level: "info"
  # Limit on number of concurrent manifests generate requests. Any value less the 1 means no limit.
  reposerver.parallelism.limit: "1"
  # Disable TLS on the gRPC endpoint
  reposerver.disable.tls: "false"
  # The minimum SSL/TLS version that is acceptable (one of: 1.0|1.1|1.2|1.3) (default "1.2")
  reposerver.tls.minversion: "1.2"
  # The maximum SSL/TLS version that is acceptable (one of: 1.0|1.1|1.2|1.3) (default "1.3")
  reposerver.tls.maxversion: "1.3"
  # The list of acceptable ciphers to be used when establishing TLS connections. Use 'list' to list available ciphers. (default "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:TLS_RSA_WITH_AES_256_GCM_SHA384")
  reposerver.tls.ciphers: "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:TLS_RSA_WITH_AES_256_GCM_SHA384"
  # Cache expiration for repo state, incl. app lists, app details, manifest generation, revision meta-data (default 24h0m0s)
  reposerver.repo.cache.expiration: "24h0m0s"
  # Cache expiration default (default 24h0m0s)
  reposerver.default.cache.expiration: "24h0m0s"
  # Max combined manifest file size for a single directory-type Application. In-memory manifest representation may be as
  # much as 300x the manifest file size. Limit this to stay within the memory limits of the repo-server while allowing
  # for 300x memory expansion and N Applications running at the same time.
  # (example 10M max * 300 expansion * 10 Apps = 30G max theoretical memory usage).
  reposerver.max.combined.directory.manifests.size: '10M'
  # Paths to be excluded from the tarball streamed to plugins. Separate with ;
  reposerver.plugin.tar.exclusions: ""
  # Allow repositories to contain symlinks that leave the boundaries of the repository.
  # Changing this to "true" will not allow _all_ out-of-bounds symlinks. Those will still be blocked for things like values
  # files in Helm charts. But symlinks which are not explicitly blocked by other checks will be allowed.
  reposerver.allow.oob.symlinks: "false"
  # Maximum size of tarball when streaming manifests to the repo server for generation
  reposerver.streamed.manifest.max.tar.size: "100M"
  # Maximum size of extracted manifests when streaming manifests to the repo server for generation
  reposerver.streamed.manifest.max.extracted.size: "1G"
  # Enable git submodule support
  reposerver.enable.git.submodule: "true"
  # Number of concurrent git ls-remote requests. Any value less than 1 means no limit.
  reposerver.git.lsremote.parallelism.limit: "0"
  # Git requests timeout.
  reposerver.git.request.timeout: "15s"

  # Disable TLS on the HTTP endpoint
  dexserver.disable.tls: "false"

  ## ApplicationSet Controller Properties
  # Enable leader election for controller manager. Enabling this will ensure there is only one active controller manager.
  applicationsetcontroller.enable.leader.election: "false"
  # "Modify how application is synced between the generator and the cluster. Default is 'sync' (create & update & delete), options: 'create-only', 'create-update' (no deletion), 'create-delete' (no update)"
  applicationsetcontroller.policy: "sync"
  # Print debug logs. Takes precedence over loglevel
  applicationsetcontroller.debug: "false"
  # Set the logging format. One of: text|json (default "text")
  applicationsetcontroller.log.format: "text"
  # Set the logging level. One of: debug|info|warn|error (default "info")
  applicationsetcontroller.log.level: "info"
  # Enable dry run mode
  applicationsetcontroller.dryrun: "false"
  # Enable git submodule support
  applicationsetcontroller.enable.git.submodule: "true"
  # Enables use of the Progressive Syncs capability
  applicationsetcontroller.enable.progressive.syncs: "false"
  # A list of glob patterns specifying where to look for ApplicationSet resources. (default is only the ns where the controller is installed)
  applicationsetcontroller.namespaces: "argocd,argocd-appsets-*"
  # Path of the self-signed TLS certificate for SCM/PR Gitlab Generator
  applicationsetcontroller.scm.root.ca.path: ""
  # A comma separated list of allowed SCM providers (default "" is all SCM providers).
  # Setting this field is required when using ApplicationSets-in-any-namespace, to prevent users from
  # sending secrets from `tokenRef`s to disallowed `api` domains.
  # The url used in the scm generator must exactly match one in the list
  applicationsetcontroller.allowed.scm.providers: "https://git.example.com/,https://gitlab.example.com/"
  # To disable SCM providers entirely (i.e. disable the SCM and PR generators), set this to "false". Default is "true".
  applicationsetcontroller.enable.scm.providers: "false"

  ## Argo CD Notifications Controller Properties
  # Set the logging level. One of: debug|info|warn|error (default "info")
  notificationscontroller.log.level: "info"
  # Set the logging format. One of: text|json (default "text")
  notificationscontroller.log.format: "text"
  # Enable self-service notifications config. Used in conjunction with apps-in-any-namespace. (default "false")
  notificationscontroller.selfservice.enabled: "false"
```

# Docker stuff (via https://github.com/surfer190/fixes/blob/master/docs/docker/docker-basics.md?plain=1)

### Getting inside a running container

There is the docker way with `docker exec` or the linux way with `nsenter`.

#### Docker Exec

The easiest and best way.

Docker exec with an interactive and pseudo-TTY:

    docker exec -it 657d80a6401d /bin/bash

You can check what else is running in the container with:

    ps -ef

    root@422ed51e84fc:/# ps -ef
    UID        PID  PPID  C STIME TTY          TIME CMD
    root         1     0  0 10:49 pts/0    00:00:00 /bin/bash
    root        22     0  0 12:02 pts/1    00:00:00 /bin/bash
    root        32    22  0 12:02 pts/1    00:00:00 ps -ef

whereas if we do the same thing on an lxd container:

    lxc exec third -- /bin/bash

there will be a lot more processes:

    root@third:~# ps -ef
    UID        PID  PPID  C STIME TTY          TIME CMD
    root         1     0  0 11:59 ?        00:00:00 /sbin/init
    root        53     1  0 11:59 ?        00:00:00 /lib/systemd/systemd-journald
    root        65     1  0 11:59 ?        00:00:00 /lib/systemd/systemd-udevd
    systemd+   155     1  0 11:59 ?        00:00:00 /lib/systemd/systemd-networkd
    systemd+   157     1  0 11:59 ?        00:00:00 /lib/systemd/systemd-resolved
    root       191     1  0 11:59 ?        00:00:00 /usr/lib/accountsservice/accounts-daemon
    syslog     192     1  0 11:59 ?        00:00:00 /usr/sbin/rsyslogd -n
    daemon     194     1  0 11:59 ?        00:00:00 /usr/sbin/atd -f
    root       195     1  0 11:59 ?        00:00:00 /lib/systemd/systemd-logind
    root       196     1  0 11:59 ?        00:00:00 /usr/sbin/cron -f
    message+   199     1  0 11:59 ?        00:00:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-
    root       204     1  0 11:59 ?        00:00:00 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
    root       213     1  0 11:59 console  00:00:00 /sbin/agetty -o -p -- \u --noclear --keep-baud console 115200,38400,9600 vt220
    root       216     1  0 11:59 ?        00:00:00 /usr/sbin/sshd -D
    root       217     1  0 11:59 ?        00:00:00 /usr/lib/policykit-1/polkitd --no-debug
    root       221     1  0 11:59 ?        00:00:00 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
    root       304     0  0 12:01 ?        00:00:00 /bin/bash
    root       314   304  0 12:01 ?        00:00:00 ps -ef

`systemd` is installed and running on the `lxc` container. On docker, it is not present.

That shows that lxd containers are meant to be full vm's, whereas docker containers are processed based.

> You can't just start an empty container - well you can but it will exit successfully every time.

You can also run additional processes in the background via `docker exec -d` - but think long and hard before doing so. You will lose repeatability and is useful only for debugging.

> If you're tempted to do this, you would probably reap bigger gains from rebuilding your container image to launch both processes in a repeatable way

### Nsenter

Part of `util-linux`, `nsenter` allows you to enter any linux namespace.

They are the core of what makes a container a container.

You can use docker to install `nsenter` on the docker server:

    docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter

* this will only work on a linux docker host

> You should be very careful about doing this! It's always a good idea to check out what you are running, and particularly what you are exposing part of your filesystem to, before you run a third-party container on your system

> With `-v`, we're telling Docker to expose the host's `/usr/local/bin` directory into the running container as `/target`

> it is then copying an executable into that directory on our host's filesystem

More stuff on `nsenter` in the book

#### Docker Volume

List the volumes stored in your root directory

    docker volume ls

> These volumes are not bind-mounted volumes, but special data containers that are useful for persisting data

Create a volume with:

    docker volume create my-data

You can start a container with this volume attached to it:

    docker run --rm --mount source=my-data,target=/app ubuntu:latest touch /app/my-persistent-data

Delete a volume with:

    docker volume rm my-data

### Logging

> Logging is a critical part of any production application

You might expect logs to write to a local logfile, to the kernel buffer `dmesg` or to `systemd` available from `journalctl`. However none of these work because of container restrictions.

Docker makes logging easier because it captures all of the normal text output from applications in the containers it manages.
Anything send to `stdout` or `stderr` is captured by the docker daemon and sent to a configurable logging backend.

#### docker logs

The default logging mechanism.

Get logs with: `docker logs <container_id>`

Nice because you get logs remotely and on demand.

Options for logging:

* `docker logs 422ed51e84fc --tail 50`
* `docker logs 422ed51e84fc -f`
* `docker logs 422ed51e84fc --since 2002-10-02`

The actual files with the logs in are at: `/var/lib/docker/containers/<container_id>/`

Downsides to this form of logging:

* log rotation
* access to logs after rotation
* disk space usage for high-volume logging

You'll want to make sure you specify the `--log-opt max-size` and `--log-opt max-file` settings if running in production.

### Configurable Logging Backends

`json-file`, `syslog`, `fluentd`, `journald`, `gelf`, `awslogs`, `splunk`, `etwlogs`, `gcplogs` and `logentries`

The simplest for running docker at scale is `syslog`.

You can specify this with `--log-driver=syslog` or setting it as the default in `daemon.json`

`daemon.json` file is the configuration for the `dockerd` server found in `/etc/docker/`

Unless you run `json-file` or `journald`, you will lose the ability to use the `docker logs` command

Many companies already have a syslog architecture in place so it makes it a easy migration path. Newer linux distributions use `systemd` and `journald`

You should be cautious about streaming logs from Docker to a remote log server over TCP or TLS, both run on top of connection-oriented TCP sessions.

> If it fails to make the connection, it will block trying to start the container. If you are running this as your default logging mechanism, this can strike at any time on any deployment.

We encourage you to use the `UDP` option for syslog logging if you intend to use the syslog driver. However, that means logs are not encrypted and not guaranteed delivery.

_We err on the side of reliability_

You can log directly to a remote syslog-compatible server from a single container by setting the log option syslog-address similar to this:

    --log-opt syslog-address=udp://192.168.42.42:123

Most logging pluggins are blocking by default. You can change this setting with: `--log-opt mode=non-blocking`

Then setting the max size: `--log-opt max-buffer-size=4m`

> The application will no longer block when that buffer fills up. Instead, the oldest loglines in memory will be dropped.


# Example of a chart uninstaller

```
Sure, let's break down the Kubernetes manifest and explain each part, including the Helm annotations:

# 1. `apiVersion`: Specifies the version of the Kubernetes API to use. In this case, it's using the RBAC (Role-Based Access Control) API, version 1.

# 2. `kind`: Defines the type of Kubernetes resource being defined. Here, it's a Role, which is a set of permissions within a namespace.

# 3. `metadata`: Contains metadata about the resource, such as its name and annotations.

#    - `name`: Specifies the name of the Role, which is "ethos-core-tee-caddy-sync-hook" in this case.

#    - `annotations`: Annotations are metadata attached to the object. They are key-value pairs used to add arbitrary non-identifying information to the object. In this manifest, annotations are used for Helm and ArgoCD hooks.

# 4. Helm annotations:

#    - `helm.sh/hook`: Indicates that this Role is used as a Helm hook. Specifically, it's a pre-install hook, meaning it executes before the installation of the chart.

#    - `helm.sh/hook-delete-policy`: Specifies the deletion policy for Helm hooks. In this case, it's set to execute before the hook is created.

#    - `helm.sh/hook-weight`: Assigns a weight to the Helm hook. A lower weight value means the hook executes earlier in the Helm lifecycle. Here, it's set to "-1", indicating it should run before other hooks.

# 5. ArgoCD annotations:

#    - `argocd.argoproj.io/hook`: Indicates that this resource is an ArgoCD hook. It specifies the type of hook; in this case, it's a PreSync hook, which runs before a synchronization operation.

#    - `argocd.argoproj.io/hook-delete-policy`: Specifies the deletion policy for ArgoCD hooks. Here, it's set to execute before the hook is created.

#    - `argocd.argoproj.io/sync-wave`: Assigns a synchronization wave to the ArgoCD hook. A lower value means the hook will be executed earlier during synchronization. "-1" indicates it should be executed in the first wave.

# 6. `namespace`: Specifies the namespace in which the Role will be created. It's set to "ethos-core-tee-caddy".

# 7. `rules`: Defines the permissions (rules) associated with the Role.

#    - Each rule specifies a set of API groups, resources, and verbs.

#    - The first rule grants permissions to get and list deployments within the "apps" API group.

#    - The second rule grants permission to delete a deployment named "tee-caddy" within the "apps" API group.

#    - The third rule grants permissions to get, list, and delete a VerticalPodAutoscaler named "tee-caddy-vpa" within the "autoscaling.k8s.io" API group.



apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ethos-core-tee-caddy-sync-hook
  annotations:
    # Add helm hook annotations for allowing local validation of the hooks using plain helm commands
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: "-1"
    # Add argocd hook annotations for readability purpose only
    # Based on  https://argo-cd.readthedocs.io/en/stable/user-guide/helm/#helm-hooks , ArgoCD already knows how to map helm
    # annotations to argocd annotations
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
    argocd.argoproj.io/sync-wave: "-1"
  namespace: ethos-core-tee-caddy
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  resourceNames: ["tee-caddy"]
  verbs: ["delete"]
- apiGroups: ["autoscaling.k8s.io"]
  resources: ["verticalpodautoscalers"]
  resourceNames: ["tee-caddy-vpa"]
  verbs: ["get", "list", "delete"]
```
