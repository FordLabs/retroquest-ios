@Library('retroquest-ios-build') _

pipeline {
    agent {
        label 'MacOS'
    }
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }
    stages {
        stage('Setup Environment Vars') {
            steps {
                echo "Setting up environment"
                script {
                    writeFile file: "env-vars.sh", text: "export RETROQUEST_SERVER_URL="+retroenvs.retroquestserver+";export APP_CENTER_SECRET="+retroenvs.appcentersecret
                    sh "cat env-vars.sh"
                }
            }
        }

        stage('Install Dev Dependencies') {
            steps {            
                echo "Running ${env.BUILD_ID}"
                sh "brew bundle --no-upgrade"
                sh "bundle install"
            }
        }

        stage('Build Xcodeproj') {
            steps {
                sh "xcodegen generate"
            }
        }

        stage('Run Tests') {
            steps {
                sh "bundle exec fastlane tests"
            }
        }
        
        stage('Build') {
            steps {
                sh "bundle exec fastlane run increment_version_number version_number:\"1.${env.BUILD_ID}\""
                sh "bundle exec fastlane beta"
            }
        }

        stage('Deploy app') {
            steps {
                withCredentials([string(credentialsId: 'app-center-api-token', variable: 'API_TOKEN')]) {
                    sh '''
                        UPLOAD_RESPONSE=$(curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "X-API-Token: $API_TOKEN" "https://api.appcenter.ms/v0.1/apps/dev-dev-central-station/com.ford.fordlabs.retroquest/release_uploads")
                        UPLOAD_ID=$(echo $UPLOAD_RESPONSE | jq -r '.upload_id')
                        UPLOAD_URL=$(echo $UPLOAD_RESPONSE | jq -r '.upload_url')
                        curl -F "ipa=@retroquest.ipa" $UPLOAD_URL
                        RELEASE_ID=$(curl -X PATCH --header 'Content-Type: application/json' --header 'Accept: application/json' --header "X-API-Token: $API_TOKEN" -d '{ "status": "committed"  }' "https://api.appcenter.ms/v0.1/apps/dev-dev-central-station/com.ford.fordlabs.retroquest/release_uploads/$UPLOAD_ID" | jq -r '.release_id')
                        curl -X PATCH --header 'Content-Type: application/json' --header 'Accept: application/json' --header "X-API-Token: $API_TOKEN" -d '{ "distribution_group_name": "Collaborators" }' "https://api.appcenter.ms/v0.1/apps/dev-dev-central-station/com.ford.fordlabs.retroquest/releases/$RELEASE_ID"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            archiveArtifacts artifacts: 'retroquest.ipa, retroquest.app.dSYM.zip'
        }
    }
    
}
