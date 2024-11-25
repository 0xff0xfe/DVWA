pipeline {
  agent any
  stages {
    stage ('Check-Git-Secrets') {
      steps {
        sh 'rm trufflehog || true'
        sh 'docker run gesellix/trufflehog --json https://github.com/0xff0xfe/DVWA.git > trufflehog'
        sh 'cat trufflehog'
      }
    }
    stage('SonarQube analysis') {
      steps {
        withSonarQubeEnv(credentialsId: 'DVWA-SonarQubeScan', installationName: 'Sonarqube') {
            script {
                def SONAR_REPORT_FILE = "./sonarqube-report.json"
                sh "docker run --rm -v ${WORKSPACE}:/usr/src -e SONAR_TOKEN=${SONAR_AUTH_TOKEN} sonarsource/sonar-scanner-cli -Dsonar.sources=./dvwa -Dsonar.projectKey=DVWA-SonarQubeScan -Dsonar.host.url=http://10.0.5.69:9000" 
                sh "curl -s -u ${SONAR_AUTH_TOKEN}: http://10.0.5.69:9000/api/issues/search?projects=DVWA-SonarQubeScan -o ${SONAR_REPORT_FILE}"
            }
        }
      }
    }
    stage('DefectDojoPublisher') {
        steps {
            withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {
                script{
                  def currentDate = new Date().format("yyyy-MM-dd")
                  def defectDojoUrl = 'http://10.0.5.69:8555/api/v2/import-scan/'  // Replace with your DefectDojo URL
                  def engagementName = 'SonarQube Scan Result'  // Replace with an engagement name
                  def scanType = 'SonarQube API Import'
                  def SONAR_REPORT_FILE = "./sonarqube-report.json"
                  
                  sh """
  
                  curl -i -X POST \\
                    '${defectDojoUrl}' \\
                    -H 'Authorization: Token ${Defect_Dojo_API_Key}' \\
                    -F 'product_name=Jenkins-CICD' \\
                    -F 'scan_date=currentDate'
                    -F 'scan_type=${scanType}' \\
                    -F 'engagement_name=${engagementName}' \\
                    -F 'verified=False' \\
                    -F 'active=True' \\
                    -F 'minimum_severity=Info' \\
                    -F 'description=Created by automated script' \\
                    -F 'auto_create_context=True' \\
                    -F 'deduplication_on_engagement=True' \\
                    -F 'file=@${SONAR_REPORT_FILE};type=application/json' \\
                  
                  """
                }
            }
        }
    }
  }
}
