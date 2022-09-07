pipeline {
    agent any

    stages {
        stage('checkout') {
            steps {
                echo 'Hello World'
                git credentialsId: '6659caf8-95a2-4201-b6e0-bfe65e71836d',
                url: 'git@github.com:Dannecron/netology-devops-ansible-vector.git',
                branch: 'main'
            }
        }
        stage('test') {
            steps {
                echo 'Run molecule test'
                sh 'molecule test'
            }
        }
    }
}
