pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Checkout your source code from your Git repository
                git url: 'https://github.com/spiral99/storder.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Install any dependencies required for your tests
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run Robot Framework Tests') {
            steps {
                // Run Robot Framework tests
                sh 'python3 -m rflint --ignore LineTooLong  storder'
                sh 'python3 -m robot.run --NoStatusRC --variable SERVER:${CT_SERVER} --outputdir log  storder/tests/'
                sh 'python3 -m robot.rebot --merge --output log/output.xml -l log/report.html -r log/report.html'
            }
        }
    }

    post {
        always {
            // Archive test results and artifacts
            script {
                step(
                    [
                        $class              : 'RobotPublisher',
                        outputPath          : 'reports',
                        outputFileName      : '**/output.xml',
                        reportFileName      : '**/report.html',
                        logFileName         : '**/log.html',
                        disableArchiveOutput: false,
                        passThreshold       : 50,
                        unstableThreshold   : 40,
                        otherFiles          : "**/*.png,**/*.jpg",
                    ]
                )
            }
        }
    }
}
