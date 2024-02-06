ARG EVENT_EXPORTER_VERSION="v1.0.0"

FROM caicloud/event-exporter:$EVENT_EXPORTER_VERSION as event-exporter


#--------------------------------------------#
#--------Build Custom Argo Image-------------#
#--------------------------------------------#

FROM debian:bookworm
# docker pull debian:bookworm
# Switch to root for the ability to perform install
USER root

COPY --from=event-exporter /event_exporter /event_exporter

RUN apt-get update && apt-get install -y coreutils bash bash-completion

USER nobody

ENTRYPOINT ["/event_exporter"]

EXPOSE 9102



# ARG ARGO_CD_VERSION="v2.6.7"
# # https://github.com/argoproj/argo-cd/blob/master/Dockerfile
# ARG KSOPS_VERSION="v4.3.1"

# #--------------------------------------------#
# #--------Build KSOPS and Kustomize-----------#
# #--------------------------------------------#

# FROM viaductoss/ksops:$KSOPS_VERSION as ksops-builder

# #--------------------------------------------#
# #--------Build Custom Argo Image-------------#
# #--------------------------------------------#

# FROM argoproj/argocd:$ARGO_CD_VERSION

# # Switch to root for the ability to perform install
# USER root

# ARG PKG_NAME=ksops

# # Override the default kustomize executable with the Go built version
# COPY --from=ksops-builder /usr/local/bin/kustomize /usr/local/bin/kustomize

# # Add ksops executable to path
# COPY --from=ksops-builder /usr/local/bin/ksops /usr/local/bin/ksops

# # Switch back to non-root user
# USER argocd


# # FROM debian:stretch-slim

# # COPY bin/event_exporter /

# # USER nobody

# # ENTRYPOINT ["/event_exporter"]

# # EXPOSE 9102
