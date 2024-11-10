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
   stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv(‘Sonarqube’) {
                        def scannerHome = tool name: 'Sonarqube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                        def scannerCmd = "${scannerHome}/bin/sonar-scanner"
                        sh "${scannerCmd} -Dsonar.projectKey=ProjectName -Dsonar.sources=./ -Dsonar.host.url=Sonarqubelink -Dsonar.login=${SONAR_TOKEN} -Dsonar.java.binaries=./"
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
