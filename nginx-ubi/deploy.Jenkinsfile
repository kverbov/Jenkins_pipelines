pipeline {
	options {
		ansiColor('xterm')
		buildDiscarder(logRotator(artifactDaysToKeepStr: '14', artifactNumToKeepStr: '14', daysToKeepStr: '14', numToKeepStr: '14'))
		timestamps()
		disableConcurrentBuilds()
		skipDefaultCheckout()
	}

	agent none

	parameters {
		string(
			name: 'BRANCH',
			defaultValue: 'master',
			description: 'Specify git branch to deploy from.'
		)
		choice(
			name: 'OCP_CLUSTER',
			choices: ['devtest', 'certprod', 'drprod'],
			description: 'Specify OCP cluster to deploy to: devtest, certprod or drprod.'
		)
		string(
			name: 'NAMESPACE',
			defaultValue: 'wbau-test',
			description: 'Specify destination project/namespace.'
		)
		string(
			name: 'TAG',
			defaultValue: 'latest',
			description: 'Choose release TAG version manually'
		)
	}

	environment {
		SVC_NAME = 'nginx-ubi'
		DOMAIN_DEVTEST = 'tbank.trrr.tdepartment'
		DOMAIN_g = 'domain.department'
		DOMAIN_CERTPROD = 'bank.rrr.department'
		GIT_URL = "https://bitbucket.${env.DOMAIN_g}/scm/rdbo_dops/jenkins-pipelines.git"
		GIT_CREDS = 'trrr-rdbo-jenkins'
		IMAGE_IN_NEXUS = "docker-registry.${env.DOMAIN_g}/rdbo/common/${env.SVC_NAME}"
		IMAGE_IN_QUAY = "quay.paas.${env.DOMAIN_CERTPROD}:5000/rdbo/common_${env.SVC_NAME}"
		OPENSHIFT_API_URL_DEVTEST = "https://api.tpaas.${env.DOMAIN_DEVTEST}:6443"
		OPENSHIFT_API_USER_DEVTEST = 'trrr-rdbo-openshift'
		OPENSHIFT_API_URL_CERTPROD = "https://api.ocp.${env.DOMAIN_CERTPROD}:6443"
		OPENSHIFT_API_USER_CERTPROD = 'rrr-rdbo-openshift'
		OPENSHIFT_API_URL_DR = "https://api.ocp1.${env.DOMAIN_CERTPROD}:6443"
		OPENSHIFT_API_USER_DR = 'rrr-rdbo-openshift'
	}
	
	stages {
		stage('deploy to devtest') {
			when {
				expression {
					(params.OCP_CLUSTER == 'devtest');
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
		stage('deploy to certprod') {
			when {
				expression {
					(params.OCP_CLUSTER == 'certprod');
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
			}
		}
		stage('deploy to drprod') {
			when {
				expression {
					(params.OCP_CLUSTER == 'drprod');
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
			}
		}
	}
}
