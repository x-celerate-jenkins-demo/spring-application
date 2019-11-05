pipeline {
    agent {
        kubernetes {
            label "xcelerate-spring-${UUID.randomUUID().toString()}"
            defaultContainer "jnlp"
            yamlFile "jenkins-agent.yml"
            inheritFrom "docker"
        }
    }
    options {
        buildDiscarder( logRotator( numToKeepStr: '5' ) )
    }
    environment {
        IMAGE_NAME = "rainerfrey/xcelerate-spring-application"
    }
    stages {
        stage( 'Checkout' ) {
            steps {
                script {
                    version = sh returnStdout: true, script: '. ./gradle.properties && echo -n $version'
                }
                checkout scm
            }
        }
        stage( 'Run Checks' ) {
            steps {
                container( 'gradle' ) {
                    script {
                        sh "./gradlew -Dspring.profiles.include=ci --full-stacktrace check"
                    }
                }
            }
            post {
                always {
                    junit 'build/test-results/test/*.xml'
                    publishHTML( target: [allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "build/reports/tests/test/", reportFiles: 'index.html', reportName: 'Test Results'] )
                }
            }
        }
        stage( 'Build' ) {
            steps {
                container( 'gradle' ) {
                    sh './gradlew clean assemble'
                }
               container( 'docker' ) {
                   script {
                       tag = "${env.IMAGE_NAME}:${version}.${env.BUILD_NUMBER}"
                       image = docker.build( tag, "-f Dockerfile --build-arg VERSION=${version}.${env.BUILD_NUMBER} ." )
                   }
               }
            }
        }
        stage( 'Publish' ) {
            steps {
               container( 'docker' ) {
                   script {
                       image.push()
                   }
               }
            }
        }
        stage( 'Test Container' ) {
            agent {
                kubernetes {
                    yaml """
                    apiVersion: v1
                    kind: Pod
                    metadata:
                      namespace: build
                      labels:
                        project: x-celerate-spring-application
                    spec:
                      containers:
                        - name: spring-application
                          image: ${env.IMAGE_NAME}:${version}.${env.BUILD_NUMBER}
                          env:
                            - name: SPRING_PROFILES_ACTIVE
                              value: production
                          resources:
                            requests:
                              memory: "256Mi"
                              cpu: "100m"
                            limits:
                              memory: "512Mi"
                              cpu: "500m"
                          
                    """
                }
            }
            steps {
                sh "curl -v http://localhost:8080/"
                containerLog "spring-application"
            }
        }
    }
}
