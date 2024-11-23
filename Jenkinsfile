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
                  def defectDojoUrl = 'http://10.0.5.69:9000/api/v2/import-scan/'  // Replace with your DefectDojo URL
                  def testId = '3'  // Replace with the correct test ID
                  def scanType = 'SonarQube Scan'
                  def SONAR_REPORT_FILE = "./sonarqube-report.json"
              
                  sh """
  
                  curl -i -X POST \\
                    '${defectDojoUrl}' \\
                    -H 'accept: application/json' \\
                    -H 'Authorization: Token ${Defect_Dojo_API_Key}' \\
                    -H 'Content-Type: multipart/form-data' \\
                    -F 'test=${testId}' \\
                    -F 'file=@${SONAR_REPORT_FILE};type=application/json' \\
                    -F 'scan_type=${scanType}' \\
  
                  """
                }
            }
        }
    }
  }
}
