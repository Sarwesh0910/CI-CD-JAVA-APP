pipeline {
  agent any

  environment {
    DOCKER_IMAGE = 'sarweshvaran/my-java-app'
    DOCKER_CREDENTIALS_ID = 'Dockerhub-key'
  }

  triggers {
    githubPush()
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/sarweshvaran/my-java-app.git' // Replace after repo is created
      }
    }

    stage('Build & Test') {
      steps {
        sh 'mvn clean test'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonar_server') {
          sh 'mvn sonar:sonar'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 1, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh "docker build -t $DOCKER_IMAGE ."
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh """
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $DOCKER_IMAGE
          """
        }
      }
    }

    stage('Deploy Locally') {
      steps {
        sh "docker run -d -p 8080:8080 $DOCKER_IMAGE"
      }
    }
  }

  post {
    success {
      echo '🎉 Pipeline completed successfully!'
    }
    failure {
      echo '❌ Pipeline failed. Check logs for details.'
    }
  }
}
