pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sivaganesh07/devopsexamapp"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        CD_REPO_URL = "https://github.com/sivaganga9786/Exam-app-demo.git"
        CD_REPO_BRANCH = "main"
        K8S_MANIFEST_PATH = "manifests/devops-app" // Path in CD repo
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/sivaganga9786/Exam-app-demo.git'
            }
        }

        stage('File System Scan') {
            steps {
                sh "trivy fs --security-checks vuln,config --format table -o trivy-fs-report.html ."
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh """
                    ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectName=devops-exam-app \
                    -Dsonar.projectKey=devops-exam-app \
                    -Dsonar.sources=. \
                    -Dsonar.language=py \
                    -Dsonar.python.version=3 \
                    -Dsonar.host.url=http://54.84.30.150:9000 
                    """
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                dir('backend') {
                    script {
                        withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                            sh "docker build -t ${DOCKER_IMAGE} ."
                            // Push the image to Docker Hub if needed
                            sh "docker push ${DOCKER_IMAGE}"
                        }
                    }
                }
            }
        }

        // Added Docker Scout Image Analysis
        stage('Docker Scout Image Analysis') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker-scout quickview ${DOCKER_IMAGE}"
                        sh "docker-scout cves ${DOCKER_IMAGE}"
                        sh "docker-scout recommendations ${DOCKER_IMAGE}"
                    }
                }
            }
        }
        stage('Update CD Repo') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'GIT_PASS', usernameVariable: 'GIT_USER')]) {
                    sh """
                    git clone -b ${CD_REPO_BRANCH} https://$GIT_USER:$GIT_PASS@${CD_REPO_URL} cd-repo
                    cd cd-repo/${K8S_MANIFEST_PATH}
                    # Update image tag in deployment.yaml
                    sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|' deployment.yaml
                    git config user.email "jenkins@example.com"
                    git config user.name "Jenkins CI"
                    git add deployment.yaml
                    git commit -m "Update image to ${IMAGE_TAG}"
                    git push origin ${CD_REPO_BRANCH}
                    """
                }
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}
