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
        string(
            name: 'FEATURE_BRANCH_URI',
            defaultValue: 'feature/test',
            description: 'Feature branch name (example: feature/login)'
        )
    }

    environment {
        REGISTRY = "abhilashkonda77/enterprise-website"
        IMAGETAG = "${env.BUILD_NUMBER}"
        GIT_CREDENTIALS = 'github_creds'
        DOCKER_CREDENTIALS = 'docker_creds'
        KUBECONFIG = "/home/jenkins/.kube/config"
        SONARQUBE_URL = "https://sonarcloud.io"
        SONARQUBE_TOKEN = credentials('SonarQubeToken')
    }

    triggers {
        githubPush()
    }

    stages {

        /* ---------------- CHECKOUT SCM ---------------- */
        stage('Checkout SCM') {
            steps {
                script {
                    if (params.TEST_FEATURE_BRANCH) {
                        echo "Building feature branch: ${params.FEATURE_BRANCH_URI}"
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: "*/${params.FEATURE_BRANCH_URI}"]],
                            userRemoteConfigs: [[
                                url: 'https://github.com/Abhilashkonda77/Enterprise-WebSite',
                                credentialsId: GIT_CREDENTIALS
                            ]]
                        ])
                    } else {
                        echo "Building main branch"
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: '*/main']],
                            userRemoteConfigs: [[
                                url: 'https://github.com/Abhilashkonda77/Enterprise-WebSite',
                                credentialsId: GIT_CREDENTIALS
                            ]]
                        ])
                    }
                }
            }
        }

        /* ---------------- SONARQUBE ---------------- */
        stage('Static Analysis (SonarQube)') {
            steps {
                script {
                    echo 'Running SonarQube Analysis...'
                    sh """
                        sonar-scanner \
                        -Dsonar.projectKey=sechay-web-app \
                        -Dsonar.organization=sechay-team \
                        -Dsonar.host.url=${SONARQUBE_URL} \
                        -Dsonar.login=${SONARQUBE_TOKEN}
                    """
                }
            }
        }

        /* ---------------- UNIT TESTS ---------------- */
        stage('Run Tests') {
            steps {
                script {
                    echo 'Running Unit Tests...'
                    sh 'ng test --watch=false --browsers=ChromeHeadless'
                }
            }
        }

        /* ---------------- DOCKER BUILD ---------------- */
        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t ${REGISTRY}:${IMAGETAG} ."
                }
            }
        }

        /* ---------------- TRIVY SCAN ---------------- */
        stage('Scan Image with Trivy') {
            steps {
                script {
                    echo 'Scanning Docker image with Trivy...'
                    sh "trivy image --severity CRITICAL ${REGISTRY}:${IMAGETAG}"
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
                to: 'abhilashkonda770@gmail.com',
                body: "The build ${currentBuild.fullDisplayName} has failed. Please check the Jenkins console output for more details."
            )
        }
    }
}
