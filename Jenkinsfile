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
        script{
          docker.image('2433ac783140').inside{
             sh "Dsonar.projectKey=DVWA-SonarQubeScan -Dsonar.sources=. -Dsonar.host.url=http://52.62.57.177:9000 -Dsonar.token=sqp_168782ad896422a8577399a1821eba74e9a02e17"
          }
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
