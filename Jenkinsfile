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
    stage('DefectDojoPublisher') {
        steps {
            withCredentials([string(credentialsId: 'Defect_Dojo_API_Key')]) {
                defectDojoPublisher(artifact: 'dependency-check-report.xml', productName: 'Jenkins-CICD', scanType: 'Dependency Check Scan', engagementName: 'DefectDojo-CICD', defectDojoCredentialsId: API_KEY, sourceCodeUrl: 'https://github.com/0xff0xfe/DVWA.git', branchTag: 'master')
            }
        }
    }
  }
}
