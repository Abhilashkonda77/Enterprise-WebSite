pipeline {
    agent any 

    parameters {
        booleanParam(
            name: 'ENABLE_BLUE_GREEN',
            defaultValue: true,
            description: 'Enable Blue-Green deployment?'
        )
        booleanParam(
            name: 'TEST_FEATURE_BRANCH',
            defaultValue: true,
            description: 'Test Feature Branch before merging to Main?'
        )
    }

    environment {
        REGISTRY = "docker pull abhilash369/sechay_website:v1"
        IMAGETAG = "${env.BUILD_NUMBER}"
        GIT_CREDENTIALS = 'github_creds'
        DOCKER_CREDENTIALS = 'docker_creds'
        KUBECONFIG = "/home/jenkins/.kube/config"
        SONARQUBE_URL = "https://sonarcloud.io"
        SONARQUBE_TOKEN = "SonarQubeToken"
    }

    triggers {
        githubPush()  // This should be a valid trigger, ensure that GitHub webhook is set up
    }

    stages {
        // 1. Checkout SCM
        stage('Checkout SCM') {
            steps {
                script {
                    if (params.TEST_FEATURE_BRANCH) {
                        // Checkout feature branch dynamically
                        echo "Building feature branch: ${params.FEATURE_BRANCH_URI}"
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: "*/${params.FEATURE_BRANCH_URI.split('/').last()}"]],
                            userRemoteConfigs: [[
                                url: 'https://github.com/Abhilashkonda77/Enterprise-WebSite',
                                credentialsId: 'github_creds'
                            ]]
                        ])
                    } else {
                        // Checkout main branch (default behavior)
                        echo "Building main branch"
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: '*/main']],
                            userRemoteConfigs: [[
                                url: 'https://github.com/Abhilashkonda77/Enterprise-WebSite',
                                credentialsId: 'github_creds'
                            ]]
                        ])
                    }
                }
            }
        }

        // 2. Static Analysis (SonarQube)
        stage('Static Analysis (SonarQube)') {
            steps {
                script {
                    echo 'Running SonarQube Analysis...'
                    sh """
                    sonar-scanner \
                    -Dsonar.projectKey=sechay-web-app \
                    -Dsonar.organization=sechay-team \
                    -Dsonar.host.url=$SONARQUBE_URL \
                    -Dsonar.login=$SONARQUBE_TOKEN
                    """
                }
            }
        }

        // 3. Run Tests & Unit Tests
        stage('Run Test') {
            steps {
                script {
                    echo 'Running Unit Tests...'
                    sh 'ng test --watch=false --browsers=ChromeHeadless'
                }
            }
        }

        // 4. Build Docker Image
        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh 'docker build -t abhilashkonda77/enterprise-website:${IMAGETAG} .'
                }
            }
        }

        // 5. Scan Image with Trivy
        stage('Scan Image with Trivy') {
            steps {
                script {
                    echo 'Scanning Docker image with Trivy...'
                    sh 'trivy image --severity CRITICAL abhilashkonda77/enterprise-website:${IMAGETAG}'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Build was successful!'
        }
        failure {
            echo 'Build failed!'
            emailext(
                subject: "Jenkins Build Failed: ${currentBuild.fullDisplayName}",
                to: 'abhilashkonda770@gmail.com'
            )
        }
    }
}
