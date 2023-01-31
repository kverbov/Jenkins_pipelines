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
	   	
   	triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'rbTrigBy', value: '$.actor.name'],
                [key: 'emailTrigBy', value: '$.actor.emailAddress'],
                [key: 'nameTrigBy', value: '$.actor.displayName'],
                [key: 'toRef', value: '$.pullRequest.toRef.id'],
				[key: 'fromRef', value: '$.pullRequest.fromRef.id'],
                [key: 'sha', value: '$.pullRequest.fromRef.latestCommit'],
				[key: 'prDesc', value: '$.pullRequest.title']
            ],
            causeString: 'Started by WEBHOOK - Create PR by $nameTrigBy, $rbTrigBy ($emailTrigBy)',
            token: 'rdbo_android',
            regexpFilterExpression: '',        // добавить, если нужно будет фильтровать срабатывание триггера по значению
            regexpFilterText: '',
            printContributedVariables: true,
            printPostContent: true
        )
    }

	stages {
		stage('Parsing webhook') {
			steps {
                build(job: "rdbo/android/build-Android", 
                    parameters: [
                        string(name: "BRANCH", value: fromRef),
                        string(name: "toRef", value: toRef),
                        string(name: "rbTrigBy", value: rbTrigBy),
                        string(name: "nameTrigBy", value: nameTrigBy),
                        string(name: "PLAINTEXT_COMMENT", value: prDesc),
                        string(name: "sha", value: sha)
                    ],
                    propagate: false,
                    wait: false)
                    print(""" *** MONITORING PARAMETERS ***
    Исходная ветка: ${fromRef}
    Конечная ветка: ${toRef}
    rb автора: ${rbTrigBy}
    ФИО автора: ${nameTrigBy}
    Описание: ${prDesc}
    Хэш коммита: ${sha}
                    """)
            }
		}
	}
}
