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
		 choice(
			name: 'PROJECT',
			choices: ['dbzm', 'glae', 'sgia', 'bis', 'artbank'],
			description: "select project aka openshift namespace"
		)
		choice(
			name: 'CONNECTOR_TYPE',
			choices: ['debezium', 'sink', 'source', 'mm'],
			description: "Debezium = DB -> Kafka\nSink = Kafka -> DB (via Kafka Connect w/ Sink Connector)\nSource = DB -> Kafka (via Kafka Connect w/ Source Connector)\nmm = Kafka -> Kafka (via Kafka Connect w/ Mirror Maker 2)"
		)
		string(
			name: 'CONNECTOR_NAME',
			defaultValue: '',
			description: "Name of debezium/sink/source instance"
		)
		choice(
			name: 'STAND',
			choices: ['test', 'cert', 'prod']
		)
		choice(
			name: 'TAG',
			choices: ['1.4.2.Final', 'latest', '1.9.4.Final'],
			description: "Choose 1.4.2 if u're in doubt. Use latest only for test purposes"
		)
	}

	environment {
		SVC_NAME = 'kafka-connect'
		GIT_URL = 'https://bitbucket.domain.department/scm/rdbo_dops/jenkins-pipelines.git'
		BRANCH = 'master'
	}
	
	stages {
		stage('deploy to devtest') {
			when {
				expression {
					params.STAND == 'dev' || params.STAND == 'test'
				}
			}
			agent {
				node { 
					label 'rdbo_evo_ocp4devtest' 
				}
			}
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
				withCredentials([
					usernamePassword(
						credentialsId: 'trrr-rdbo-openshift',
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD')
				]) {
					sh """
						cd ${env.SVC_NAME}
						make deploy
					"""
					echo 'Post deploy clean up'
					sh '''
						shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					'''
				}
			}
		}
		stage('deploy to certprod') {
			when {
				expression {
					params.STAND == 'cert' || params.STAND == 'prod'
				}
			}
			agent {
				node {
					label 'rdbo_evo_ocp4certprod' 
				}
			}
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
				withCredentials([
					usernamePassword(
						credentialsId: 'rrr-rdbo-openshift',
						usernameVariable: 'OPENSHIFT_USERNAME',
						passwordVariable: 'OPENSHIFT_PASSWORD')
				]) {
					sh """
						cd ${env.SVC_NAME}
						make deploy
					"""
					echo 'Post deploy clean up'
					sh '''
						shopt -s dotglob && cd "${WORKSPACE}" && rm -rf ./* # Fix for VSCode linter : */
					'''
				}
			}
		}
	}
}
