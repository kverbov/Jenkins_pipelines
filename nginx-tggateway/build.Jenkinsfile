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
		SVC_NAME = 'nginx-tggateway'
		g_DOMAIN = 'domain.department'
		TEST_DOMAIN = 'tbank.trrr.tdepartment'
		PROD_DOMAIN = 'bank.rrr.department'
		NEXUS = "docker-registry.${g_DOMAIN}"
		IMAGE_IN_NEXUS = "${NEXUS}/rdbo/common/${SVC_NAME}:${TAG}"
		NEXUS_CREDS_RDBO_RW = 'trrx-facade-docker'
		GIT_URL = "https://bitbucket.${g_DOMAIN}/scm/rdbo_dops/jenkins-pipelines.git"
		GIT_CREDS = 'trrr-rdbo-jenkins'
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
						docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASS} ${NEXUS} && \
						docker build -t "${env.IMAGE_IN_NEXUS}" . && \
						docker push "${env.IMAGE_IN_NEXUS}"
					"""
				}
			}
		}
		/*
		stage ('scan image') {
			steps {
				prismaCloudScanImage (
					ca: '',
					cert: '',
					ignoreImageBuildTime: true,
					dockerAddress: 'unix:///var/run/docker.sock',
					image: "${env.IMAGE_IN_NEXUS}",
					key: '',
					logLevel: 'info',
					podmanPath: '',
					project: '',
					resultsFile: 'prisma-cloud-scan-results.json'
				)
				prismaCloudPublish resultsFilePattern: 'prisma-cloud-scan-results.json'
			}
		}
		*/
	}
	post {
		always {
			sh """
				rm -rf "${WORKSPACE}"/* # */
			"""
		}
	}
}
