pipeline {
  agent any
  environment {
  
  // Define ZAP remote server details
	ZAP_IP = '54.206.117.228'
	DVWA_IP = '3.107.194.18'
	CURRENT_DATE = ''	  
  }
  
  stages {
    stage ('Check-Git-Secrets') {
      steps {
        sh 'rm trufflehog || true'
        sh '''
          docker run --rm -i -v "$PWD:/pwd" trufflesecurity/trufflehog:latest github --json --repo https://github.com/0xff0xfe/DVWA.git > trufflehog.json
        '''
        archiveArtifacts artifacts: 'trufflehog.json'

        withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {

       
                //Import Trufflehog scan Report
                script{
                  def currentDate = new Date().format("yyyy-MM-dd")
		  env.CURRENT_DATE = currentDate
                  def defectDojoUrl = "http://10.0.5.69:8555/api/v2/reimport-scan/"  // Replace with your DefectDojo URL
                  def productName = "Jenkins-CICD"
                  def engagementName = "Truffle-hog scan"  // Replace with an engagement name
                  def descName = "Created by automated script"
                  def scanType = "Trufflehog Scan"
                  def sonarReportFile = "/var/lib/jenkins/workspace/webapp-cicd-pipeline/trufflehog.json"
                  
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
    
    stage('OWASP Dependency Check') {
        steps {
            dependencyCheck additionalArguments: '--scan ./ --enableExperimental', nvdCredentialsId: 'nvd-api-token', odcInstallation: 'DVWA-DP-Check'
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
              

             withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {

       
                //Import Dependency Check Report
                script{
                  def currentDate = new Date().format("yyyy-MM-dd")
		  env.CURRENT_DATE = currentDate
                  def defectDojoUrl = "http://10.0.5.69:8555/api/v2/reimport-scan/"  // Replace with your DefectDojo URL
                  def productName = "Jenkins-CICD"
                  def engagementName = "Owasp DependencyCheck"  // Replace with an engagement name
                  def descName = "Created by automated script"
                  def scanType = "Dependency Check Scan"
                  def sonarReportFile = "/var/lib/jenkins/workspace/webapp-cicd-pipeline/dependency-check-report.xml"
                  
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
   
    stage('SonarQube analysis') {
      steps {
        withSonarQubeEnv('Sonarqube') {
            script{
              def SONAR_REPORT_FILE = "./sonarqube-report.json"
              sh "docker run --rm -v ${WORKSPACE}:/usr/src -e SONAR_TOKEN=${SONAR_AUTH_TOKEN} sonarsource/sonar-scanner-cli -Dsonar.sources=./dvwa -Dsonar.projectKey=DVWA-SonarQube-Scan -Dsonar.host.url=http://10.0.5.69:9000 -Dsonar.qualitygate.wait=true" 
              sh "curl -s -u ${SONAR_AUTH_TOKEN}: http://10.0.5.69:9000/api/issues/search?projects=DVWA-SonarQube-Scan -o ${SONAR_REPORT_FILE}"
            }
          }

          withCredentials([string(credentialsId: 'Defect_Dojo_API_Key', variable: 'Defect_Dojo_API_Key')]) {

       
                //Import Sonarqube Scan Report
                script{
                  def currentDate = new Date().format("yyyy-MM-dd")
		  env.CURRENT_DATE = currentDate
                  def defectDojoUrl = "http://10.0.5.69:8555/api/v2/reimport-scan/"  // Replace with your DefectDojo URL
                  def productName = "Jenkins-CICD"
                  def engagementName = "SonarQube Scan"  // Replace with an engagement name
                  def descName = "Created by automated script"
                  def scanType = "SonarQube Scan"
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
   
    
   stage('DAST') {
    steps {
        sshagent(['zap']) {
            sh '''#!/bin/bash
              # Run the Docker container in detached mode
              container_id=$(ssh -o StrictHostKeyChecking=no ubuntu@${ZAP_IP} "docker container run -v \$(pwd):/zap/wrk/:rw -t zaproxy/zap-weekly zap.sh -cmd -autorun /zap/wrk/FullScanDvwaAuth.yaml")
              
              # Wait for the Docker container to finish executing
              exit_code=$(ssh -o StrictHostKeyChecking=no ubuntu@${ZAP_IP} "docker wait ${container_id}")
              
              # Define report file names
              ZAP_HTML_FILE="${ZAP_IP}-ZAP-Report-${DVWA_IP}.html"
              ZAP_XML_FILE="${ZAP_IP}-ZAP-Report-${DVWA_IP}.xml"

              # Download the reports
              scp ubuntu@${ZAP_IP}:./${ZAP_XML_FILE} ./${ZAP_XML_FILE}
              scp ubuntu@${ZAP_IP}:./${ZAP_HTML_FILE} ./${ZAP_HTML_FILE}

              echo "Exit Code: ${exit_code}"

              # Save exit code for Groovy to use later if needed
              echo "${exit_code}" > exit_code.txt
            '''
            
            // Now in Groovy, after shell execution
            script {
                def exitCode = readFile('exit_code.txt').trim()
                def zapHtmlFile = "${env.ZAP_IP}-ZAP-Report-${env.DVWA_IP}.html"

                publishHTML([
                  allowMissing: false,
                  alwaysLinkToLastBuild: false,
                  keepAll: false,
                  reportDir: '.',
                  reportFiles: zapHtmlFile,
                  reportName: 'HTML Report',
                  reportTitles: '',
                  useWrapperFileDirectly: true
                ])

                echo "Exit Code: ${exitCode}"

                if (exitCode != '0') {
                    error("OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML report.")
                } else {
                    echo "OWASP ZAP did not report any Risk"
                }
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
