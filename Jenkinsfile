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
    stage ('OWASP Dependency-Check Vulnerabilities') {
            steps {
                dependencyCheck additionalArguments: ''' 
                    -o "./" 
                    -s "./"
                    -f "ALL" 
                    --prettyPrint''', odcInstallation: 'DVWA-DP-Check'

                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
      }
     stage('SonarQube analysis') {
      steps {
        withSonarQubeEnv(credentialsId: 'DVWA-SonarQubeScan'){
             sh "docker run sonarsource/sonar-scanner-cli -X -Dsonar.projectKey=DVWA-SonarQubeScan -Dsonar.host.url=http://10.0.5.69:9000"
             sh "cat target/sonar/report-task.txt"
        }
      }
    }
    stage('DefectDojoPublisher') {
        steps {
            withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {
                defectDojoPublisher(artifact: 'dependency-check-report.xml', productName: 'Jenkins-CICD', scanType: 'Dependency Check Scan', engagementName: 'DefectDojo-CICD', defectDojoCredentialsId: 'Defect_Dojo_API_Key', sourceCodeUrl: 'https://github.com/0xff0xfe/DVWA.git', branchTag: 'master')
            }
        }
    }
  }
}
