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
        git branch: 'main', url: 'https://github.com/Sarwesh0910/CI-CD-JAVA-APP.git'
      }
    }

    stage('Build & Test') {
      steps {
        echo '🔧 Running Maven build and tests...'
        bat 'mvn clean test'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        echo ' Running SonarQube analysis...'
        withSonarQubeEnv('sonar_server') {
          bat 'mvn sonar:sonar'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo ' Waiting for SonarQube quality gate result...'
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Build') {
      steps {
        echo " Building Docker image: %DOCKER_IMAGE%"
        bat "docker build -t %DOCKER_IMAGE% ."
      }
    }

    stage('Push to DockerHub') {
      steps {
        echo ' Pushing image to DockerHub...'
        withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat """
            echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
            docker push %DOCKER_IMAGE%
          """
        }
      }
    }

    stage('Deploy Locally') {
      steps {
        echo ' Deploying container locally on port 8080...'
        bat "docker run -d -p 8080:8080 %DOCKER_IMAGE%"
      }
    }
  }

  post {
    success {
      echo ' Pipeline completed successfully!'
    }
    failure {
      echo ' Pipeline failed. Check logs for details.'
    }
    always {
      echo ' Archiving build artifacts...'
      archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
    }
  }
}
