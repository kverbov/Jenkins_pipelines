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

	agent none

	parameters {
		string(
			name: 'BRANCH',
			defaultValue: 'master',
			description: 'Specify git branch to deploy from.'
		)
		choice(
			name: 'STAND',
			choices: ['dev', 'test', 'cert', 'prod', 'dr'],
			description: 'Specify destination stand: dev, test, cert, prod or dr.'
		)
		string(
			name: 'NAMESPACE',
			defaultValue: 'drrr-common',
			description: 'Specify destination project/namespace.'
		)
	}

	environment {
		SVC_NAME = 'prometheus'
		DOMAIN_DEVTEST = 'tbank.trrr.tdepartment'
		DOMAIN_g = 'domain.department'
		DOMAIN_CERTPROD = 'bank.rrr.department'
		GIT_URL = "https://bitbucket.${env.DOMAIN_g}/scm/rdbo_dops/jenkins-pipelines.git"
		GIT_CREDS = 'trrr-rdbo-jenkins'
		TAG = 'latest'
		IMAGE_IN_NEXUS = "docker-registry.${env.DOMAIN_g}/rdbo/tools/${env.SVC_NAME}"
		IMAGE_IN_QUAY = "quay.paas.${env.DOMAIN_CERTPROD}:5000/rdbo/tools_${env.SVC_NAME}"
		OPENSHIFT_API_URL_DEVTEST = "https://api.tpaas.${env.DOMAIN_DEVTEST}:6443"
		OPENSHIFT_API_USER_DEVTEST = 'trrr-rdbo-openshift'
		OPENSHIFT_API_URL_CERTPROD = "https://api.ocp.${env.DOMAIN_CERTPROD}:6443"
		OPENSHIFT_API_USER_CERTPROD = 'rrr-rdbo-openshift'
		OPENSHIFT_API_URL_DR = "https://api.ocp1.${env.DOMAIN_CERTPROD}:6443"
		OPENSHIFT_API_USER_DR = 'rrr-rdbo-openshift'
	}
	
	stages {
		stage('deploy to dev') {
			when {
				expression {
					(params.STAND == 'dev');
				}
			}
			agent { label 'rdbo_evo_ocp4devtest' }
			environment {
				IMAGE = "${env.IMAGE_IN_NEXUS}"
				DOMAIN = "${env.DOMAIN_DEVTEST}"
				OPENSHIFT_API_URL = "${env.OPENSHIFT_API_URL_DEVTEST}"
				OPENSHIFT_API_USER = "${env.OPENSHIFT_API_USER_DEVTEST}"
			}
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info "${IMAGE}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
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
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OPENSHIFT_API_USER}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh 'bash ./"${SVC_NAME}"/deploy.sh'
				}
				sh '''shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */'''
			}
		}
		stage('deploy to test') {
			when {
				expression {
					(params.STAND == 'test');
				}
			}
			agent { label 'rdbo_evo_ocp4devtest' }
			environment {
				IMAGE = "${env.IMAGE_IN_NEXUS}"
				DOMAIN = "${env.DOMAIN_DEVTEST}"
				OPENSHIFT_API_URL = "${env.OPENSHIFT_API_URL_DEVTEST}"
				OPENSHIFT_API_USER = "${env.OPENSHIFT_API_USER_DEVTEST}"
			}
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info "${IMAGE}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
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
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OPENSHIFT_API_USER}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh 'bash ./"${SVC_NAME}"/deploy.sh'
				}
				sh '''shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */'''
			}
		}
		stage('deploy to cert') {
			when {
				expression {
					(params.STAND == 'cert');
				}
			}
			agent { label 'rdbo_evo_ocp4certprod' }
			environment {
				IMAGE = "${env.IMAGE_IN_QUAY}"
				DOMAIN = "${env.DOMAIN_CERTPROD}"
				OPENSHIFT_API_URL = "${env.OPENSHIFT_API_URL_CERTPROD}"
				OPENSHIFT_API_USER = "${env.OPENSHIFT_API_USER_CERTPROD}"
			}
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info --insecure=true "${IMAGE}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
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
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OPENSHIFT_API_USER}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh 'bash ./"${SVC_NAME}"/deploy.sh'
				}
				sh '''shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */'''
			}
		}
		stage('deploy to prod') {
			when {
				expression {
					(params.STAND == 'prod');
				}
			}
			agent { label 'rdbo_evo_ocp4certprod' }
			environment {
				IMAGE = "${env.IMAGE_IN_QUAY}"
				DOMAIN = "${env.DOMAIN_CERTPROD}"
				OPENSHIFT_API_URL = "${env.OPENSHIFT_API_URL_CERTPROD}"
				OPENSHIFT_API_USER = "${env.OPENSHIFT_API_USER_CERTPROD}"
			}
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info --insecure=true "${IMAGE}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
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
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OPENSHIFT_API_USER}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh 'bash ./"${SVC_NAME}"/deploy.sh'
				}
				sh '''shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */'''
			}
		}
		stage('deploy to dr') {
			when {
				expression {
					(params.STAND == 'dr');
				}
			}
			agent { label 'rdbo_evo_ocp4drprod' }
			environment {
				IMAGE = "${env.IMAGE_IN_QUAY}"
				DOMAIN = "${env.DOMAIN_CERTPROD}"
				OPENSHIFT_API_URL = "${env.OPENSHIFT_API_URL_DR}"
				OPENSHIFT_API_USER = "${env.OPENSHIFT_API_USER_DR}"
			}
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info --insecure=true "${IMAGE}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
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
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OPENSHIFT_API_USER}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh 'bash ./"${SVC_NAME}"/deploy.sh'
				}
				sh '''shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */'''
			}
		}
	}
}
