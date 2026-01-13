pipeline {
    agent any

    /* Multibranch pipelines already do checkout */
    options {
        skipDefaultCheckout(true)
    }

    parameters {
        booleanParam(
            name: 'TEST_FEATURE_BRANCH',
            defaultValue: true,
            description: 'Test feature branch before merging to main'
        )
        string(
            name: 'FEATURE_BRANCH_URI',
            defaultValue: 'feature/test',
            description: 'Feature branch name (e.g. feature/login)'
        )
    }

    environment {
        REGISTRY           = 'abhilashkonda77/enterprise-website'
        IMAGETAG           = "${env.BUILD_NUMBER}"
        GIT_CREDENTIALS    = 'github-pat'
        DOCKER_CREDENTIALS = 'docker_creds'
        KUBECONFIG         = '/home/jenkins/.kube/config'

        SONARQUBE_URL   = 'https://sonarcloud.io'
        SONARQUBE_TOKEN = credentials('SonarQubeToken')
    }


    stages {

        /* ---------------- CHECKOUT SCM ---------------- */
        stage('Checkout SCM') {
            steps {
                script {
                    def branchName = params.TEST_FEATURE_BRANCH
                        ? params.FEATURE_BRANCH_URI
                        : 'main'

                    echo "Building branch: ${branchName}"

                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${branchName}"]],
                        userRemoteConfigs: [[
                            url: 'https://github.com/Abhilashkonda77/Enterprise-WebSite',
                            credentialsId: env.GIT_CREDENTIALS
                        ]]
                    ])
                }
            }
        }

        /* ---------------- SONARQUBE ---------------- */
        stage('Static Analysis (SonarQube)') {
          steps {
            script {
                def scannerHome = tool 'SonarScanner'
                sh """
                    ${scannerHome}/bin/sonar-scanner \
                          -Dsonar.projectKey=sechay-web-app \
                          -Dsonar.organization=sechay-team \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=${SONARQUBE_URL} \
                          -Dsonar.login=${SONARQUBE_TOKEN} \
                          -Dsonar.exclusions=**/node_modules/**,**/dist/**
                """
                }
            }
        }


        /* ---------------- UNIT TESTS ---------------- */
        stage('Smoke Tests') {
            steps {
                script {
                    echo 'Smoke testing files......'
                    sh '''
                        test -f index.html
                        test -f login.js
                        node --check login.js
                '''
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
            echo '✅ Build was successful!'
        }

        failure {
            echo '❌ Build failed!'
            emailext(
                subject: "Jenkins Build Failed: ${currentBuild.fullDisplayName}",
                to: 'abhilashkonda770@gmail.com',
                body: """
                The build ${currentBuild.fullDisplayName} has failed.

                Please check the Jenkins console output for more details.
                """
            )
        }
    }
}
