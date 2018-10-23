@Library('pipeline-lib') _

def MAIN_BRANCH                    = 'master'
def DOCKER_REGISTRY_URL            = 'https://registry.hub.docker.com'
def DOCKER_REGISTRY_CREDENTIALS_ID = '6992a9de-fab7-4932-9907-3aba4a70c4c0'
def IMAGE_PREFIX                   = 'salemove'

def generateTags = { version ->
  def major, minor, patch

  (major, minor, patch) = version.tokenize('.')

  ["${major}.${minor}", version]
}

def buildAgentImage = { agentName ->
  def dockerfile, imageName, dockerImage, version

  version = readFile("${agentName}.version").trim()
  dockerfile = "${agentName}.dockerfile"
  imageName = "${IMAGE_PREFIX}/${agentName}"

  ansiColor('xterm') {
    dockerImage = docker.build(imageName, "-f ${dockerfile} .")

    if (BRANCH_NAME == MAIN_BRANCH) {
      stage('Publish ${dockerImage.imageName()}') {
        generateTags(version).each { tag ->
          echo("Publishing docker image ${dockerImage.imageName()} with tag ${tag}")
          dockerImage.push(tag)
        }
      }
    }
  }
}

withResultReporting(slackChannel: '#tm-engage') {
  inDockerAgent() {
    stage('Checkout code') {
      checkout(scm)
    }

    // prerequisite for other images
    stage("Build jenkins-agent-docker") {
      buildAgentImage('jenkins-agent-docker')
    }

    parallel(
      "Node.js": { buildAgentImage('jenkins-agent-node') },
      "Python": { buildAgentImage('jenkins-agent-python') },
      "Ruby 2.2": { buildAgentImage('jenkins-agent-ruby-2.2') },
      "Ruby 2.4": { buildAgentImage('jenkins-agent-ruby-2.4') },
      "Ruby 2.5": { buildAgentImage('jenkins-agent-ruby-2.5') }
    )
  }
}
