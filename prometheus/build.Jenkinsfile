pipeline {
	options {
		ansiColor('xterm')
		buildDiscarder(
			logRotator(
				artifactDaysToKeepStr: '14',
				artifactNumToKeepStr: '14',
				daysToKeepStr: '14',
				numToKeepStr: '14'
			)
		)
		timestamps()
		disableConcurrentBuilds()
	}

	agent {
		node { 
			label 'rdbo_evo_cloud_build'
		}
	}
	
	parameters {
		string(
			name: 'BRANCH',
			defaultValue: 'master',
			description: 'Specify build branch manually'
		)
	}
	
	environment {
		GIT_URL = 'https://bitbucket.tbank.trrr.tdepartment/scm/rdbo_dops/jenkins-pipelines.git'
		GIT_CREDS = 'trrr-rdbo-jenkins'
		NEXUS_CREDS_RDBO_RW = 'trbx-facade-docker'
	}

	stages {
		stage('checkout') {
			steps {
				cleanWs()
				checkout([
					$class: 'GitSCM',
					branches: [[name: "${params.BRANCH}"]],
					doGenerateSubmoduleConfigurations: false,
					extensions: [[$class: 'CleanBeforeCheckout']],
					submoduleCfg: [],
					userRemoteConfigs: [[
						url: "${env.GIT_URL}",
						credentialsId: "${env.GIT_CREDS}"
					]]
				])
			}
		}
		stage('build & push') {
			environment {
				CI_REGISTRY = "docker-registry.tbank.trrr.tdepartment"
				DOCKER_IMAGE_NAME = "prometheus"
				DOCKERFILE_FOLDER = "prometheus"
			}
			steps {
				withCredentials([
					usernamePassword(
						credentialsId: "${env.NEXUS_CREDS_RDBO_RW}",
						passwordVariable: 'CI_REGISTRY_PASS',
						usernameVariable: 'CI_REGISTRY_USER')
				]) {
					sh '''
						set -xe
						cd "${DOCKERFILE_FOLDER}"
						make docker_push
					'''
				}
			}
		}
	}

	post {
		success {
			script {
				sh '''shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */'''
			}
		}
	}
}
