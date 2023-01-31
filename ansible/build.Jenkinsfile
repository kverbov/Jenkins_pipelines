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
		SVC_NAME = 'ansible'
		TAG = 'latest'
		g_DOMAIN = 'domain.department'
		TEST_DOMAIN = 'tbank.trrr.tdepartment'
		PROD_DOMAIN = 'bank.rrr.department'
		NEXUS = "docker-registry.${g_DOMAIN}"
		IMAGE_IN_NEXUS = "${NEXUS}/rdbo/tools/${SVC_NAME}:${TAG}"
		NEXUS_CREDS_RDBO_RW = 'trrx-facade-docker'
		QUAY = "quay.paas.${PROD_DOMAIN}:5000"
		IMAGE_IN_QUAY = "${QUAY}/rdbo/tools_${SVC_NAME}:${TAG}"
		OPENSHIFT_API_URL_DEVTEST = "https://openshift.paas.${TEST_DOMAIN}:8443"
		OPENSHIFT_API_URL_CERTPROD = "https://openshift.paas.${PROD_DOMAIN}:8443"
		BRANCH = 'master'
		GIT_URL = "https://bitbucket.${g_DOMAIN}/scm/rdbo_dops/jenkins-pipelines.git"
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
						docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASS} ${NEXUS} && \
						docker build -t "${env.IMAGE_IN_NEXUS}" . && \
						docker tag "${env.IMAGE_IN_NEXUS}" "${env.IMAGE_IN_QUAY}" && \
						docker push "${env.IMAGE_IN_NEXUS}" && \
						docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASS} ${QUAY} && \
						docker push "${env.IMAGE_IN_QUAY}"
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
