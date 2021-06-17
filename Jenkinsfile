@Library('pipeline-lib') _

def MAIN_BRANCH                    = 'master'
def DOCKER_REGISTRY_URL            = 'https://registry.hub.docker.com'
def DOCKER_REGISTRY_CREDENTIALS_ID = '6992a9de-fab7-4932-9907-3aba4a70c4c0'
def IMAGE_PREFIX                   = 'salemove'

def generateTags = { version, revision ->
  def (major, minor, patch) = version.tokenize('.')

  ["${major}.${minor}", version, "${version}-${revision}"]
}

def buildAgentImage = { agentName, minorVersion=null ->
  def fileSuffix = minorVersion ? "-${minorVersion}" : ""
  def version = readFile("${agentName}${fileSuffix}.version").trim()
  def revision = sh(script: 'git log -n 1 --pretty=format:\'%h\'', returnStdout: true)
  def dockerFile = "${agentName}${fileSuffix}.dockerfile"

  def imageName = "${IMAGE_PREFIX}/${agentName}:${version}-${revision}"

  ansiColor('xterm') {
    def dockerImage = docker.build(imageName, "--pull -f ${dockerFile} .")

    if (BRANCH_NAME == MAIN_BRANCH) {
      stage("Publish ${dockerImage.imageName()}") {
        generateTags(version, revision).each { tag ->
          echo("Publishing docker image ${dockerImage.imageName()} with tag ${tag}")

          docker.withRegistry(DOCKER_REGISTRY_URL, DOCKER_REGISTRY_CREDENTIALS_ID) {
            dockerImage.push(tag)
          }
        }
      }
    }
  }
}

withResultReporting(slackChannel: '#tm-inf') {
  inDockerAgent(containers: [agentContainer(image: 'salemove/jenkins-agent-docker:17.12.0')]) {
    stage('Checkout code') {
      checkout(scm)
    }

    stage("Build jenkins-agent-docker") {
      buildAgentImage('jenkins-agent-docker')
    }
  }
}
