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
		choice(name: 'STAND', choices: ['test', 'cert', 'prod', 'dr'], description: 'Choose deploy stand')
		choice(name: 'TAG', choices: ['2.6.4'], description: 'Choose release TAG version manually')
	}

	environment {
		SVC_NAME = 'zipkin-dependencies'
		PROJ = 'jenkins-pipelines'
		TEST_DOMAIN = 'tbank.trrr.tdepartment'
		g_DOMAIN = 'domain.department'
		PROD_DOMAIN = 'bank.rrr.department'
		GIT_URL = "https://bitbucket.${env.g_DOMAIN}/scm/RDBO_DOPS/${env.PROJ}.git"
		GIT_CREDS = 'trrr-rdbo-jenkins'
		IMAGE_IN_NEXUS = "docker-registry.${env.g_DOMAIN}/rdbo/common/${env.SVC_NAME}"
		IMAGE_IN_QUAY = "quay.paas.${env.PROD_DOMAIN}:5000/rdbo/tools_${env.SVC_NAME}"
		OCP4_DEVTEST = "https://api.tpaas.${env.TEST_DOMAIN}:6443"
		OCP4_DEVTEST_CREDS = 'trrr-rdbo-openshift'
		OCP4_DEVTEST_NS = 'retail-devtest'
		OCP4_CERTPROD = "https://api.ocp.${env.PROD_DOMAIN}:6443"
		OCP4_CERTPROD_CREDS = 'rrr-rdbo-openshift'
		OCP4_CERTPROD_NS = 'retail-certprod'
		OCP4_DR = "https://api.ocp1.${env.PROD_DOMAIN}:6443"
		OCP4_DR_CREDS = 'rrr-rdbo-openshift'
		OCP4_DR_NS = 'retail-certprod'
		JAVA_TOOL_OPTIONS = '-Djava.rmi.server.hostname=192.168.1.2'
		JAVA_OPTS = '-server -Xms1G -Xmx1G -XX:+UseContainerSupport -XX:+AlwaysActAsServerClassMachine -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication -Djdk.nio.maxCachedBufferSize=262144'
	}

	stages {
		stage('deploy to devtest') {
			when {
				expression {
					params.STAND == 'dev' || params.STAND == 'test'
				}
			}
			agent { label 'rdbo_evo_ocp4devtest' }
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info "${IMAGE_IN_NEXUS}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE_IN_NEXUS}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
				checkout([
					$class: 'GitSCM',
					branches: [[name: "${params.BRANCH}"]],
					doGenerateSubmoduleConfigurations: false,
					extensions: [
						[$class: 'CleanBeforeCheckout'],
						[$class: 'RelativeTargetDirectory', relativeTargetDir: 'git']
					],
					submoduleCfg: [],
					userRemoteConfigs: [[
						url: "${env.GIT_URL}",
						credentialsId: "${env.GIT_CREDS}"
					]]
				])
				script {
					sh "sed -i 's|%SVC_NAME%|${SVC_NAME}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%NAMESPACE%|${OCP4_DEVTEST_NS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%STAND%|${STAND}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%IMAGE%|${IMAGE_IN_NEXUS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%TAG%|${TAG}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%JAVA_TOOL_OPTIONS%|${JAVA_TOOL_OPTIONS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%JAVA_OPTS%|${JAVA_OPTS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i '/envFrom/,/eszp/d' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
				}
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OCP4_DEVTEST_CREDS}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh "oc login ${OCP4_DEVTEST} -u=${OPENSHIFT_USERNAME}@${TEST_DOMAIN} -p=${OPENSHIFT_PASSWORD} -n=${OCP4_DEVTEST_NS} --insecure-skip-tls-verify=true && \
						oc process -f ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml | oc apply -f -"
					echo "Deploying ${SVC_NAME} to Openshift4 ${OCP4_DEVTEST_NS}(${STAND}) from image ${IMAGE_IN_NEXUS}:${TAG} COMPLETED."
				}
			}
		}
		stage('deploy to certprod') {
			when {
				expression {
					params.STAND == 'cert' || params.STAND == 'prod'
				}
			}
			agent { label 'rdbo_evo_ocp4certprod' }
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info "${IMAGE_IN_NEXUS}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE_IN_NEXUS}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
				checkout([
					$class: 'GitSCM',
					branches: [[name: "${params.BRANCH}"]],
					doGenerateSubmoduleConfigurations: false,
					extensions: [
						[$class: 'CleanBeforeCheckout'],
						[$class: 'RelativeTargetDirectory', relativeTargetDir: 'git']
					],
					submoduleCfg: [],
					userRemoteConfigs: [[
						url: "${env.GIT_URL}",
						credentialsId: "${env.GIT_CREDS}"
					]]
				])
				script {
					sh "oc image mirror ${IMAGE_IN_NEXUS}:${TAG} ${IMAGE_IN_QUAY}:${TAG} --insecure=true --skip-mount=true --force=true"
					sh "sed -i 's|%SVC_NAME%|${SVC_NAME}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%NAMESPACE%|${OCP4_CERTPROD_NS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%STAND%|${STAND}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%IMAGE%|${IMAGE_IN_QUAY}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%TAG%|${TAG}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%JAVA_TOOL_OPTIONS%|${JAVA_TOOL_OPTIONS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%JAVA_OPTS%|${JAVA_OPTS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
				}
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OCP4_CERTPROD_CREDS}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh "oc login ${OCP4_CERTPROD} -u=${OPENSHIFT_USERNAME}@${PROD_DOMAIN} -p=${OPENSHIFT_PASSWORD} -n=${OCP4_CERTPROD_NS} --insecure-skip-tls-verify=true && \
						oc process -f ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml | oc apply -f -"
					echo "Deploying ${SVC_NAME} to Openshift4 ${OCP4_CERTPROD_NS}(${STAND}) from image ${IMAGE_IN_QUAY}:${TAG} COMPLETED."
				}
			}
		}
		stage('deploy to dr') {
			when {
				expression {
					params.STAND == 'dr' 
				}
			}
			agent { label 'rdbo_evo_ocp4drprod' }
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					oc image info --insecure=true "${IMAGE_IN_QUAY}:${TAG}"
					if (( "${?}" != 0 )); then
						echo "Src image '${IMAGE_IN_QUAY}:${TAG}' not found, aborting deploy."
						exit 1
					fi
				'''
				checkout([
					$class: 'GitSCM',
					branches: [[name: "${params.BRANCH}"]],
					doGenerateSubmoduleConfigurations: false,
					extensions: [
						[$class: 'CleanBeforeCheckout'],
						[$class: 'RelativeTargetDirectory', relativeTargetDir: 'git']
					],
					submoduleCfg: [],
					userRemoteConfigs: [[
						url: "${env.GIT_URL}",
						credentialsId: "${env.GIT_CREDS}"
					]]
				])
				script {
					sh "sed -i 's|%SVC_NAME%|${SVC_NAME}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%NAMESPACE%|${OCP4_DR_NS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%STAND%|${STAND}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%IMAGE%|${IMAGE_IN_QUAY}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%TAG%|${TAG}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%JAVA_TOOL_OPTIONS%|${JAVA_TOOL_OPTIONS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
					sh "sed -i 's|%JAVA_OPTS%|${JAVA_OPTS}|g' ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml"
				}
				withCredentials([
					usernamePassword(
						credentialsId: "${env.OCP4_DR_CREDS}",
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD'
					)
				]) {
					sh "oc login ${OCP4_DR} -u=${OPENSHIFT_USERNAME}@${PROD_DOMAIN} -p=${OPENSHIFT_PASSWORD} -n=${OCP4_DR_NS} --insecure-skip-tls-verify=true && \
						oc process -f ${WORKSPACE}/git/${SVC_NAME}/k8s.app.template.yaml | oc apply -f -"
					echo "Deploying ${SVC_NAME} to Openshift4 ${OCP4_DR_NS}(${STAND}) from image ${IMAGE_IN_QUAY}:${TAG} COMPLETED."
				}
			}
		}
	}
}
