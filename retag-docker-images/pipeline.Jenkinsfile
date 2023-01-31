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
		node { label 'rdbo_evo_ocp4devtest' }
	}

	parameters {
		choice(
			name: 'SRC_IMAGE_REGISTRY',
			choices: ['nexus', 'quay'],
			description: "Source image's location\ndev/test - nexus\ncert/prod - quay"
		)
		string(
			name: 'SRC_IMAGE',
			defaultValue: 'rdbo/bfcd/account:192.168.1.2',
			description: "Source image's {path}/{name}:{tag}"
		)
		choice(
			name: 'DST_IMAGE_REGISTRY',
			choices: ['nexus', 'quay'],
			description: "Destination image's location\ndev/test - nexus\ncert/prod - quay"
		)
		string(
			name: 'DST_IMAGE',
			defaultValue: 'rdbo/bfcd_account:192.168.1.2',
			description: "Destination image's {path}/{name}:{tag}"
		)
	}

	environment {
		TECH_DOMAIN = 'domain.department'
		PROD_DOMAIN = 'bank.rrr.department'
		NEXUS = "docker-registry.${env.TECH_DOMAIN}"
		QUAY = "quay.paas.${env.PROD_DOMAIN}:5000"
	}

	stages {
		stage('retag') {
			steps {
					sh '''
						set -xe

						#{ Error checks
						if [[ -z "${SRC_IMAGE_REGISTRY}" || -z "${SRC_IMAGE}" || -z "${DST_IMAGE_REGISTRY}" || -z "${DST_IMAGE}" ]]; then
							echo "There was at least 1 param with an empty value, but all params are necessary."
							exit 1
						fi
						if [[ "${SRC_IMAGE_REGISTRY}" = 'nexus' ]]; then
							SRC_IMAGE_REGISTRY="${NEXUS}"
						else
							SRC_IMAGE_REGISTRY="${QUAY}"
						fi
						if [[ "${DST_IMAGE_REGISTRY}" = 'nexus' ]]; then
							DST_IMAGE_REGISTRY="${NEXUS}"
						else
							DST_IMAGE_REGISTRY="${QUAY}"
						fi
						#}

						oc image mirror "${SRC_IMAGE_REGISTRY}/${SRC_IMAGE}" "${DST_IMAGE_REGISTRY}/${DST_IMAGE}" --insecure=true --skip-mount=true --force=true
					'''
			}
		}
	}
}
