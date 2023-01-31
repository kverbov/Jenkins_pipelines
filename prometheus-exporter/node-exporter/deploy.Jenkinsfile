/*def nexusApi() {
    def url = new URL("https://nexus.domain.department/service/rest/v1/search?repository=rdbo-raw&group=/ru/bank/exporters") 
    def conn = url.openConnection()
    def root = new groovy.json.JsonSlurper().parseText(conn.content.text)
    return root
}*/

def NEXUS_URL = "https://nexus.domain.department/repository/rdbo-raw/ru/bank/exporters/"
def PATH_TO_HOME = "prometheus-exporter/node-exporter"

properties([ 
    parameters([
        string(
            name: 'IPADDR',
            defaultValue: '',
            description: 'IP Addresses (delimiter ";")'
        ),
        /*credentials(
            name: 'ACCESS_CRED',
            description: 'Choose cred with sudo access to host',
            defaultValue: '',
            required: true
        ),
        [$class: 'ccccadeChoiceParameter',
            choiceType: 'PT_SINGLE_SELECT',
            filterLength: 1,
            filterable: false,
            name: 'IMAGE',
            script: [
                $class: 'GroovyScript',
                fallbackScript: [
                    classpath: [],
                    sandbox: true,
                    script: 'return ["ERROR"]'
                ],
                script: [
                    classpath: [],
                    sandbox: true,
                    script: 'res = nexusApi(); return res'
                ]
            ]
        ],*/
        string(
            name: 'IMAGE_URL',
            defaultValue: '',
            description: ''
        ),
        string(
            name: 'HOST_LOGIN',
            defaultValue: '',
            description: ''
        ),
        password(
            name: 'HOST_PASS',
            defaultValue: '',
            description: ''
        )
    ])
])

pipeline {
    options {
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactDaysToKeepStr: '14', artifactNumToKeepStr: '14', daysToKeepStr: '14', numToKeepStr: '14'))
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 15, unit: 'MINUTES')   // timeout on whole pipeline job
    }

    agent { node { label "deploy" } }

    stages {
        stage("Deploy") {
            steps {
                sh ("python3 create_inv.py ${IPADDR} ./${PATH_TO_HOME}/inventory.ini")
                script {
                    sh '''
                        cat <<EOF > deploy.sh &&
#!/bin/bash
ansible-playbook -v \
    --ssh-common-args '-o StrictHostKeyChecking=no' \
    -i ./${PATH_TO_HOME}/inventory.ini \
    "--extra-vars=nexus_url=${IMAGE_URL} \
                    ansible_user=${HOST_LOGIN} \
                    ansible_password=${HOST_PASS} \
                    pwd=$(pwd) \
                    PATH_TO_HOME=${PATH_TO_HOME} \
    ./${PATH_TO_HOME}/playbooks/exporter_deploy.yml
EOF
                        docker run --rm \
                            --name ansible-tmp  \
                            -e LANG=${LANG} \
                            -e LOCAL_USER=${USER} \
                            -e LOCAL_USER_ID=$(id -u) \
                            -e ANSIBLE_FORCE_COLOR=true \
                            -v /etc/hosts:/etc/hosts:ro \
                            -v  $(pwd):/tmp/deploy \
                            -w /tmp/deploy \
                            docker-registry.domain.department/general/ansible:2.8.0 \
                                -c '/bin/bash -xe /tmp/deploy/deploy.sh'
                    '''
                }
            }
        }
    }

	post {
		always {
			script {
				env.jobDuration = currentBuild.durationString
				env.jobDurationMs = currentBuild.duration
			}
		}
		/*success {
			wrap([$class: 'BuildUser']) {
				script {
					echo 'Post deploy clean up'
					sh '''
						shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* 
						curl -skXPOST "https://192.168.1.2:443/jenkins/deploy/${STAND}" -H 'Host: api.telegram.org' -d "✅ Deploy succeeded: 📦${project}/${application} (image tag: ${VERSION})\nDuration: ${jobDuration} (${jobDurationMs} ms)\nBuild #${BUILD_NUMBER}, started by ${BUILD_USER_EMAIL} (${BUILD_USER_ID})"
					'''
				}
			}
		}
		failure {
			wrap([$class: 'BuildUser']) {
				script {
					sh '''
						curl -skXPOST "https://192.168.1.2:443/jenkins/deploy/${STAND}" -H 'Host: api.telegram.org' -d "❌ Deploy failed! 📦${project}/${application} (image tag: ${VERSION})\nDuration: ${jobDuration} (${jobDurationMs} ms)\nBuild #${BUILD_NUMBER}, started by ${BUILD_USER_EMAIL} (${BUILD_USER_ID})"
					'''
				}
			}
		}
		aborted {
			wrap([$class: 'BuildUser']) {
				script {
					sh '''
						curl -skXPOST "https://192.168.1.2:443/jenkins/deploy/${STAND}" -H 'Host: api.telegram.org' -d "✖️ Deploy was aborted: 📦${project}/${application} (image tag: ${VERSION})\nDuration: ${jobDuration} (${jobDurationMs} ms)\nBuild #${BUILD_NUMBER}, started by ${BUILD_USER_EMAIL} (${BUILD_USER_ID})"
					'''
				}
			}
		}*/
	}
}