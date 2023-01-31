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

	environment {
		SVC_NAME = 'jdk1.8'
		TAG = 'latest'
		CI_REGISTRY = 'docker-registry.tbank.trrr.tdepartment/rdbo/common'
		CI_REGISTRY_IMAGE = "${CI_REGISTRY}/${SVC_NAME}"
		BRANCH = 'master'
		GIT_URL = 'https://bitbucket.tbank.trrr.tdepartment/scm/rdbo_dops/jenkins-pipelines.git'
	}

	stages {
		stage('checkout') {
			steps {
				checkout([
					$class: 'GitSCM',
					branches: [[name: "${env.BRANCH}"]],
					doGenerateSubmoduleConfigurations: false,
					extensions: [[$class: 'CleanBeforeCheckout']],
					submoduleCfg: [],
					userRemoteConfigs: [[
						url: "${env.GIT_URL}",
						credentialsId: 'trrr-rdbo-jenkins'
					]]
				])
			}
		}
		stage('build & push') {
			steps {
				withCredentials([
					usernamePassword(
						credentialsId: 'trbx-facade-docker',
						passwordVariable: 'CI_REGISTRY_PASS',
						usernameVariable: 'CI_REGISTRY_USER')
				]) {
					sh """
						cd "${env.SVC_NAME}"
						make docker_push
					"""
				}
			}
		}
	}
	post {
		always {
			cleanWs cleanWhenAborted: false, cleanWhenFailure: false, cleanWhenNotBuilt: false, cleanWhenUnstable: false, deleteDirs: true
		}
	}
}
