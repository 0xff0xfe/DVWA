pipeline {
  agent any
  environment {
        // Define ZAP remote server details
        REMOTE_SERVER = 'ubuntu@3.27.140.228'
        REMOTE_PATH = './2024-11-28-ZAP-Report-3.106.223.79.xml'
        ZAP_REPORT_PATH = './2024-11-28-ZAP-Report-3.106.223.79.xml'
  }
  
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
        withSonarQubeEnv('Sonarqube') {
            
                def SONAR_REPORT_FILE = "./sonarqube-report.json"
                sh "docker run --rm -v ${WORKSPACE}:/usr/src -e SONAR_TOKEN=${SONAR_AUTH_TOKEN} sonarsource/sonar-scanner-cli -Dsonar.sources=./dvwa -Dsonar.projectKey=DVWA-SonarQube-Scan -Dsonar.host.url=http://10.0.5.69:9000" 
                sh "curl -s -u ${SONAR_AUTH_TOKEN}: http://10.0.5.69:9000/api/issues/search?projects=DVWA-SonarQube-Scan -o ${SONAR_REPORT_FILE}"
        }
       timeout(time: 1, unit: 'HOURS') {
                // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                // true = set pipeline to UNSTABLE, false = don't
                waitForQualityGate abortPipeline: true
          
        }
      }
    }

    /*
    stage ('DAST') {
      steps {
        sshagent(['zap']) {
         sh 'ssh -o  StrictHostKeyChecking=no ubuntu@3.27.140.228 "docker container run -d -v $(pwd):/zap/wrk/:rw -t zaproxy/zap-weekly zap.sh -cmd -autorun /zap/wrk/FullScanDvwaAuth.yaml" || true'
        }
      }
    }

    stage('DefectDojoPublisher') {
        steps {   
            withCredentials([sshUserPrivateKey(credentialsId: 'zap', keyFileVariable: 'ZAP_SSH_KEY')]) {
                sh "scp -i $ZAP_SSH_KEY ubuntu@3.27.140.228:./2024-11-28-ZAP-Report-3.106.223.79.xml ./2024-11-28-ZAP-Report-3.106.223.79.xml"
            }
            withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {
                //Import SonarQube Scan Report
                script{
                  def currentDate = new Date().format("yyyy-MM-dd")
                  def defectDojoUrl = "http://10.0.5.69:8555/api/v2/import-scan/"  // Replace with your DefectDojo URL
                  def productName = "Jenkins-CICD"
                  def engagementName = "SonarQube Report"  // Replace with an engagement name
                  def descName = "Created by automated script"
                  def scanType = "SonarQube API Import"
                  def sonarReportFile = "/var/lib/jenkins/workspace/webapp-cicd-pipeline/sonarqube-report.json"
                  
                  sh """
                    curl -i -v -X POST "${defectDojoUrl}" \\
                      -H "Authorization: Token ${Defect_Dojo_API_Key}" \\
                      -F "scan_date=${currentDate}" \\
                      -F "scan_type=${scanType}" \\
                      -F "verified=False" \\
                      -F "active=True" \\
                      -F "minimum_severity=Info" \\
                      -F "description=${descName}" \\
                      -F "auto_create_context=True" \\
                      -F "deduplication_on_engagement=True" \\
                      -F "product_name=${productName}" \\
                      -F "engagement_name=${engagementName}" \\
                      -F "file=@${sonarReportFile};type=application/json" \\
                  """

                  //Import ZAP Scan Report
                  
                  def zapEngagementName = "Zap-Report"  // Replace with an engagement name
                  def scanTypeZap = "ZAP Scan"
                  
                  sh """
                    curl -i -v -X POST "${defectDojoUrl}" \\
                      -H "Authorization: Token ${Defect_Dojo_API_Key}" \\
                      -F "scan_date=${currentDate}" \\
                      -F "scan_type=${scanTypeZap}" \\
                      -F "verified=False" \\
                      -F "active=True" \\
                      -F "minimum_severity=Info" \\
                      -F "description=${descName}" \\
                      -F "auto_create_context=True" \\
                      -F "deduplication_on_engagement=True" \\
                      -F "product_name=${productName}" \\
                      -F "engagement_name=${zapEngagementName}" \\
                      -F "file=@${ZAP_REPORT_PATH};type=application/json" \\
                  """
                  
               }
            }
        }
    }
    */
  }
}
