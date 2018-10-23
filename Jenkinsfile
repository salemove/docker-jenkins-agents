@Library('pipeline-lib') _

def MAIN_BRANCH                    = 'master'
def DOCKER_REGISTRY_URL            = 'https://registry.hub.docker.com'
def DOCKER_REGISTRY_CREDENTIALS_ID = '6992a9de-fab7-4932-9907-3aba4a70c4c0'
def IMAGE_PREFIX                   = 'salemove'
def CPU_LIMIT_PER_BUILD            = 1
def CPU_LIMIT_TOTAL                = 6

def generateTags = { version ->
  def major, minor, patch

  (major, minor, patch) = version.tokenize('.')

  ["${major}.${minor}", version]
}

def buildAgentImage = { agentName, minorVersion=null ->
  def dockerFile, fileSuffix, imageName, dockerImage, version

  fileSuffix = minorVersion ? "-${minorVersion}" : ""
  version = readFile("${agentName}${fileSuffix}.version").trim()
  dockerFile = "${agentName}${fileSuffix}.dockerfile"

  imageName = "${IMAGE_PREFIX}/${agentName}"

  ansiColor('xterm') {
    dockerImage = docker.build(imageName, "--pull -f ${dockerFile} --cpu-period 100000 --cpu-quota ${CPU_LIMIT_PER_BUILD * 100000} .")

    if (BRANCH_NAME == MAIN_BRANCH) {
      stage("Publish ${dockerImage.imageName()}") {
        generateTags(version).each { tag ->
          echo("Publishing docker image ${dockerImage.imageName()} with tag ${tag}")

          docker.withRegistry(DOCKER_REGISTRY_URL, DOCKER_REGISTRY_CREDENTIALS_ID) {
            dockerImage.push(tag)
          }
        }
      }
    }
  }
}

withResultReporting(slackChannel: '#tm-engage') {
  inDockerAgent(
    containers: [agentContainer(
      image: 'salemove/jenkins-agent-docker:17.12.0',
      resourceRequestCpu: CPU_LIMIT_TOTAL.toString(),
      resourceLimitCpu: CPU_LIMIT_TOTAL.toString()
    )]
  ) {
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
      "Ruby 2.2": { buildAgentImage('jenkins-agent-ruby', '2.2') },
      "Ruby 2.4": { buildAgentImage('jenkins-agent-ruby', '2.4') },
      "Ruby 2.5": { buildAgentImage('jenkins-agent-ruby', '2.5') }
    )
  }
}