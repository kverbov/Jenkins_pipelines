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
		string(name: 'BRANCH', defaultValue: 'master', description: 'Branch to build from.')
		string(name: 'TAG', defaultValue: 'latest', description: "Image tag.")
	}

	environment {
		SVC_NAME = 'kafka-connect'
		GIT_URL = 'https://bitbucket.domain.department/scm/rdbo_dops/jenkins-pipelines.git'
	}

	stages {
		stage('checkout') {
			steps {
				checkout([
					$class: 'GitSCM',
					branches: [[name: "${params.BRANCH}"]],
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
						credentialsId: 'trrx-facade-docker',
						passwordVariable: 'CI_REGISTRY_PASS',
						usernameVariable: 'CI_REGISTRY_USER')
				]) {
					sh """
						cd ${SVC_NAME}
						make docker_push
					"""
				}
			}
		}
	}

	post {
		always {
			echo 'Post deploy clean up'
			sh '''
				shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
			'''
		}
	}
}
