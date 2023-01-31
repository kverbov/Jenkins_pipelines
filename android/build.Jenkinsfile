def manualStart = currentBuild.getBuildCauses('hudson.model.Cause$UserIdCause')

pipeline {
	options {
		ansiColor('xterm')
		buildDiscarder(
			logRotator(
				artifactDaysToKeepStr: '31',
				artifactNumToKeepStr: '4',
				daysToKeepStr: '14',
				numToKeepStr: '14'
			)
		)
		timestamps()
		disableConcurrentBuilds()
		skipDefaultCheckout()
	}

	agent {
		node {
			label 'rdbo_evo_cloud_android'
		}
	}

	parameters {
        string(name: 'BRANCH', defaultValue: 'master', description: 'Ветка или тэг, с которой собираем')
		string(name: 'BUILD_SCRIPT', defaultValue: 'upload-other.sh', description: 'скрипт gradle')
		booleanParam(name: 'UPLOAD_MAPPING', defaultValue: false, description: 'выгрузка файла мапинга')
		choice(name: 'TAG', choices: ['latest', 'jdk17', 'jdk11'], description: 'образ для сборки')
        string(name: 'PLAINTEXT_COMMENT', defaultValue: '', description: 'Your comment goes here (use \n to word wrap)')
        
	}

	environment {
		PROJ = 'rboa'
		NAME = 'android-client'
		g_DOMAIN = 'domain.department'
		GIT_URL = "https://bitbucket.${env.g_DOMAIN}/scm/${env.PROJ}/${env.NAME}.git"
		GIT_CREDS = 'trrr-rdbo-jenkins'
		CI_REGISTRY_CREDS_ID = "trbx-facade-docker"
	}
	   	
	stages {
		stage('checkout') {
			steps {
				echo 'Clean up current dir before git checkout'
				sh '''
					shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./*
				'''
				script {
					if (!manualStart) {
						notifyBitbucket(
							commitSha1: params.sha,
							considerUnstableAsSuccess: false,
							credentialsId: "trrr-rdbo-jenkins",
							disableInprogressNotification: true,
							ignoreUnverifiedSSLPeer: true,
							includeBuildNumberInKey: true,
							prependParentProjectKey: false,
							projectKey: 'RBOA',
							stashServerBaseUrl: "https://bitbucket.domain.department"
						)
					}
				}
				checkout([
					$class: 'GitSCM',
					branches: [[name: BRANCH]],
					doGenerateSubmoduleConfigurations: false,
					extensions: [
						[$class: 'CleanBeforeCheckout'],
						[$class: 'RelativeTargetDirectory', relativeTargetDir: "${env.NAME}"]
					],
					submoduleCfg: [],
					userRemoteConfigs: [[
						url: "${env.GIT_URL}",
						credentialsId: "${env.GIT_CREDS}"
					]]
				])
			}
		}
        stage('build') {
			steps {
				script {
					if (!manualStart) {
						if ((params.toRef == 'refs/heads/development')||(params.toRef ==~ /^(refs\/heads\/release)($|.+)/)) {
							BUILD_SCRIPT = "upload-development.sh"
						}
					}
					withCredentials([
                            usernamePassword(
                                    credentialsId: "${env.CI_REGISTRY_CREDS_ID}",
                                    passwordVariable: 'NEX_USR',
                                    usernameVariable: 'NEX_PWD')
                    ]) {
						sh """cat <<EOF > ${NAME}/credentials.properties
						USER_TRB_LOGIN=${NEX_USR}
						USER_TRB_PASSWORD=${NEX_PWD}
						EOF"""
						sh """
							podman run --rm \
							-e USER_TRB_LOGIN='${NEX_USR}' \
							-e USER_TRB_PASSWORD='${NEX_PWD}' \
							-e UPLOAD_MAPPING='${UPLOAD_MAPPING}' \
							-w /tmp/build \
							-v /jenkins/android-cache:/root/.gradle \
							-v \${PWD}/${NAME}:/tmp/build \
							docker-registry.${g_DOMAIN}/rdbo/tools/android_sdkmanager:${TAG} \
							sh -c "sh ${BUILD_SCRIPT}"
						"""
					}
				}
			}
		}
	}

	post {
        always {
            script {
                env.jobDuration = currentBuild.durationString
				env.jobDurationMs = currentBuild.duration
				env.BUILDSTATUS = currentBuild.currentResult
				if (env.BUILDSTATUS == 'FAILURE'){
					env.BUILDSTATUS = '❌'}
				else if (env.BUILDSTATUS == 'SUCCESS'){
					env.BUILDSTATUS = '✅'}
				else if (env.BUILDSTATUS == 'ABORTED'){
					env.BUILDSTATUS = '❗Aborted'}
				else {env.BUILDSTATUS = '➿Unknown'}
				if (!manualStart) {
					currentBuild.result = currentBuild.result ?: 'SUCCESS'
					notifyBitbucket(
						commitSha1: params.sha,
						considerUnstableAsSuccess: false,
						credentialsId: "trrr-rdbo-jenkins",
						disableInprogressNotification: true,
						ignoreUnverifiedSSLPeer: true,
						includeBuildNumberInKey: true,
						prependParentProjectKey: false,
						projectKey: 'RBOA',
						stashServerBaseUrl: "https://bitbucket.domain.department"
					)
                    env.src = BRANCH.replace("refs/heads/", "")
					env.rbTrigBy = params.rbTrigBy
                    env.nameTrigBy = params.nameTrigBy
    				sh '''
    				    	curl -skXPOST "https://192.168.1.2:443/jenkins/build/android" -H 'Host: api.telegram.org' -d "${BUILDSTATUS}📦Android/${src}\\nWEBHOOK TRIGGER\\nRevision:${TAG}\\nDuration: ${jobDuration} (${jobDurationMs} ms)\\nAuthor: ${rbTrigBy}\\nTriggered by: ${nameTrigBy}\\nDescription: ${PLAINTEXT_COMMENT}\\nAt: $(TZ=MSK-3 date +'%F') $(TZ=MSK-3 date +'%T') UTC+3"
    					'''
    			}
				else {
					wrap([$class: 'BuildUser']) {
						sh '''
							curl -skXPOST "https://192.168.1.2:443/jenkins/build/android" -H 'Host: api.telegram.org' -d "${BUILDSTATUS}📦Android/${BRANCH}\\nMANUAL START\\nRevision:${TAG}\\nDuration: ${jobDuration} (${jobDurationMs} ms)\\nStarted by: ${BUILD_USER_ID}\\n${BUILD_USER_EMAIL}\\nComment: ${PLAINTEXT_COMMENT}\\nAt: $(TZ=MSK-3 date +'%F') $(TZ=MSK-3 date +'%T') UTC+3"
						'''
					}
				}
            }
        }
        cleanup{
            deleteDir() /* clean up our workspace */
        }
	}
}

