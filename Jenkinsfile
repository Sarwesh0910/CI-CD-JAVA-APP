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
        sh 'mvn clean test'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        echo '📊 Running SonarQube analysis...'
        withSonarQubeEnv('sonar_server') {
          sh 'mvn sonar:sonar'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo '⏳ Waiting for SonarQube quality gate result...'
        timeout(time: 1, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Build') {
      steps {
        echo "🐳 Building Docker image: $DOCKER_IMAGE"
        sh "docker build -t $DOCKER_IMAGE ."
      }
    }

    stage('Push to DockerHub') {
      steps {
        echo '📦 Pushing image to DockerHub...'
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
        echo '🚀 Deploying container locally on port 8080...'
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
    always {
      echo '📁 Archiving build artifacts...'
      archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
    }
  }
}
