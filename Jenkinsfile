pipeline {
  agent any
  environment {
        // Define ZAP remote server details
	ZAP_IP = '54.253.232.128'
	DVWA_IP = '3.106.188.21'
	CURRENT_DATE = ''	  
  }
  
  stages {
    stage ('Check-Git-Secrets') {
      steps {
        sh 'rm trufflehog || true'
        sh '''
          docker run --rm -i -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --json --repo https://github.com/0xff0xfe/DVWA.git --fail > trufflehog.json
        '''
        archiveArtifacts artifacts: 'trufflehog.json', onlyIfSuccessful: true
      }
    }
    stage('Software Composition Analysis') {
      steps {
        script {
            sh 'composer security-audit --format=.json'
        }
      }
    }
    /*  
    stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', nvdCredentialsId: 'nvd-api-token', odcInstallation: 'DVWA-DP-Check'
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }
    */
    stage('SonarQube analysis') {
      steps {
        withSonarQubeEnv('Sonarqube') {
            script{
              def SONAR_REPORT_FILE = "./sonarqube-report.json"
              sh "docker run --rm -v ${WORKSPACE}:/usr/src -e SONAR_TOKEN=${SONAR_AUTH_TOKEN} sonarsource/sonar-scanner-cli -Dsonar.sources=./dvwa -Dsonar.projectKey=DVWA-SonarQube-Scan -Dsonar.host.url=http://10.0.5.69:9000 -Dsonar.qualitygate.wait=true" 
              sh "curl -s -u ${SONAR_AUTH_TOKEN}: http://10.0.5.69:9000/api/issues/search?projects=DVWA-SonarQube-Scan -o ${SONAR_REPORT_FILE}"
            }
          }
        }
    }
    /*
     stage('DefectDojoPublisher') {
        steps {   
            withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {

       
                //Import SonarQube Scan Report
                script{
                  def currentDate = new Date().format("yyyy-MM-dd")
		  env.CURRENT_DATE = currentDate
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
               }
            }
        }
    }
    */
    
    stage('DAST') {
    steps {
        sshagent(['zap']) {
            sh '''
              # Run the Docker container in detached mode
              container_id=$(ssh -o StrictHostKeyChecking=no ubuntu@${env.ZAP_IP} "docker container run -v \$(pwd):/zap/wrk/:rw -t zaproxy/zap-weekly zap.sh -cmd -autorun /zap/wrk/FullScanDvwaAuth.yaml")
              
              # Wait for the Docker container to finish executing
              exit_code=$(ssh -o StrictHostKeyChecking=no ubuntu@${env.ZAP_IP} "docker wait ${container_id}")

              def ZAP_HTML_FILE = "${env.ZAP_IP}-ZAP-Report-${env.DVWA_IP}.html"
	      def ZAP_XML_FILE = "${env.ZAP_IP}-ZAP-Report-${env.DVWA_IP}.xml"

              scp ubuntu@${env.ZAP_IP}:./${ZAP_XML_FILE} ./${ZAP_XML_FILE}"
              scp ubuntu@${env.ZAP_IP}:./${ZAP_HTML_FILE} ./${ZAP_HTML_FILE}"
              
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '.\\', reportFiles: '${ZAP_HTML_FILE}', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
              
              echo "Exit Code: $exit_code"
          
              # Check if the exit code is non-zero (indicating an error)
              if [ ${exit_code} -ne 0 ]; then
                  echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML report."
                  exit 1
              else
                  echo "OWASP ZAP did not report any Risk"
              fi
            '''
         }
      }
   } 

    
    stage('DefectDojoPublisher') {
        steps {   
            
          
            withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {
                //Import OWASP Depedency scan result 
                defectDojoPublisher(artifact: 'dependency-check-report.xml', productName: 'Jenkins-CICD', scanType: 'Dependency Check Scan', engagementName: 'OWASP-Dependency Check Report', defectDojoCredentialsId: 'Defect_Dojo_API_Key', sourceCodeUrl: 'https://github.com/0xff0xfe/DVWA.git', branchTag: 'master')

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
    stage('Prompt to PROD?'){
	    steps{
		      timeout(time: 2, unit: 'DAYS'){
			    input 'Do you want to Approve the Deployment to Production Environment/Namespace?'
		   }
	   }
    }
  }
}
