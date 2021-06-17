ARG DOCKER_VERSION="19.03.15"
FROM docker:${DOCKER_VERSION} AS docker

FROM jenkins/inbound-agent:4.7-1-alpine

USER root

# See artifacts that need to be copied in the original Dockerfile
# https://github.com/docker-library/docker/blob/279ba9c93e8e26a15171645bd511ea8476c4706e/19.03/Dockerfile
COPY --from=docker /usr/local/bin/* /usr/local/bin/
COPY --from=docker /certs /certs

RUN echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > /etc/ssh/ssh_known_hosts

ENTRYPOINT ["docker-entrypoint.sh", "jenkins-agent"]
