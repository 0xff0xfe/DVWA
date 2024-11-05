pipeline {
  agent any
  stages {
    stage ('Check-Git-Secrets') {
      steps {
        sh 'rm trufflehog || true'
        sh 'docker run hello-world'
        //sh 'docker run gesellix/trufflehog --json https://github.com/0xff0xfe/DVWA.git > trufflehog'
        //sh 'cat trufflehog'
      }
    }  
  }
}
