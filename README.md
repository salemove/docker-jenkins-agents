# docker-jenkins-agents
Collection of Dockerfiles for Jenkins agents, intended for use [Kubernetes hosting](https://github.com/jenkinsci/kubernetes-plugin).

## jenkins-agent-docker
Agent based on [jenkins/docker-jnlp-slave](https://github.com/jenkinsci/docker-jnlp-slave) and [library/docker](https://github.com/docker-library/docker).

Agent includes common tools and libraries to build Docker images.

The agent assumes bind-mounted access to Docker:
```
docker run -v /var/run/docker.sock:/var/run/docker.sock jenkins-agent-docker
```
or for a Kubernetes pod:
```
volumes:
- name: docker
  hostPath:
    path: /var/run/docker.sock
```

## jenkins-agent-ruby

Agent based on [salemove/jenkins-agent-docker](https://github.com/salemove/docker-jenkins-agents) and [library/ruby](https://hub.docker.com/_/ruby/).

Agent includes common tools and libraries to build Ruby application Docker images.

## jenkins-agent-python

Agent based on [salemove/jenkins-agent-docker](https://github.com/salemove/docker-jenkins-agents) and [library/python](https://hub.docker.com/_/python/).

Agent includes common tools and libraries to build Python 3 application Docker images.
