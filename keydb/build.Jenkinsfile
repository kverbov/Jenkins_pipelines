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
		string(name: 'TAG', defaultValue: 'latest', description: "Image tag.")
	}

	environment {
		SVC_NAME = 'keydb'
		BRANCH = 'master'
		GIT_URL = 'https://bitbucket.domain.department/scm/rdbo_dops/jenkins-pipelines.git'
		CI_REGISTRY = 'docker-registry.domain.department/rdbo/common'
		CI_REGISTRY_IMAGE = "${env.CI_REGISTRY}/${env.SVC_NAME}"
		NEXUS_CREDS_RDBO_RW = 'trbx-facade-docker'
		GIT_CREDS = 'trrr-rdbo-jenkins'
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
						credentialsId: "${env.GIT_CREDS}"
					]]
				])
			}
		}
		stage('build & push') {
			steps {
				withCredentials([
					usernamePassword(
						credentialsId: "${env.NEXUS_CREDS_RDBO_RW}",
						usernameVariable: 'REGISTRY_USER',
						passwordVariable: 'REGISTRY_PASS')
				]) {
					sh """
						cd "${env.SVC_NAME}" && \
						docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASS} ${CI_REGISTRY} && \
						docker build --force-rm=true --pull=true \
							-t ${CI_REGISTRY_IMAGE}:${TAG} \
							--build-arg REGISTRY_USER=${REGISTRY_USER} --build-arg REGISTRY_PASS=${REGISTRY_PASS} \
							-f Dockerfile . && \
						docker push ${CI_REGISTRY_IMAGE}:${TAG}
					"""
				}
			}
		}
	}

	post {
		success {
			echo 'Post deploy clean up'
			sh '''
				shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
			'''
		}
	}
}
