pipeline {
  agent any

  environment {
    DOCKER_USER = 'sarweshvaran'
    DOCKER_IMAGE = "${DOCKER_USER}/my-java-app:latest"
    DOCKER_CREDENTIALS_ID = 'Dockerhub-key'
  }

  triggers {
    githubPush()
  }

  stages {
    stage('Checkout') {
      steps {
        echo '🔍 Checking out source code...'
        git branch: 'main', url: 'https://github.com/Sarwesh0910/CI-CD-JAVA-APP.git'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        echo '📊 Running SonarQube analysis...'
        withSonarQubeEnv('sonar_server') {
          bat 'mvn sonar:sonar'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo '⏳ Waiting for SonarQube quality gate result...'
        timeout(time: 3, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Build') {
      steps {
        echo "🐳 Building Docker image: ${DOCKER_IMAGE}"
        withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat """
            echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
            docker build -t %DOCKER_IMAGE% .
          """
        }
      }
    }

    stage('Verify Docker Image') {
      steps {
        echo '🔍 Verifying Docker image before push...'
        bat "docker images | findstr my-java-app"
      }
    }

    stage('Push to DockerHub') {
      steps {
        echo '📦 Pushing image to DockerHub...'
        withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          retry(2) {
            bat """
              echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
              docker push %DOCKER_IMAGE%
            """
          }
        }
      }
    }

    stage('Deploy Locally') {
      steps {
        echo '🚀 Deploying container locally...'
        script {
          def portCheck = bat(script: 'netstat -ano | findstr :8080', returnStatus: true)
          def deployPort = (portCheck == 0) ? '9090' : '8080'
          echo "Using port ${deployPort} for deployment"

          // Optional: stop any existing container with same image
          bat "docker ps -q --filter ancestor=${DOCKER_IMAGE} | for /f %%i in ('more') do docker rm -f %%i"

          // Run new container
          bat "docker run -d -p ${deployPort}:8080 ${DOCKER_IMAGE}"
        }
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
      archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
    }
  }
}
