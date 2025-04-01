pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-credentials'  // Jenkins credentials ID for AWS access keys
        VARS_DIR = 'vars'  // Path to the folder containing YAML files
        AWS_REGION = 'ap-southeast-2'
        BUCKET_NAME = 'terraform-state-bucket'
        STATE_KEY_PREFIX = 'appinfra'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Authenticate with AWS') {
            steps {
                script {
                    // Use the AWS credentials configured in Jenkins
                    withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, region: AWS_REGION)]) {
                        // Validate AWS authentication
                        sh '''
                        aws sts get-caller-identity
                        '''
                    }
                }
            }
        }

        stage('Load Configuration from YAML') {
            steps {
                script {
                    // Read default.yaml and the branch-specific YAML file
                    def defaultConfig = readYaml file: "${VARS_DIR}/default.yaml"
                    def branchConfigFile = "${VARS_DIR}/${env.GIT_BRANCH}.yaml"
                    def branchConfig = readYaml file: branchConfigFile

                    // Merge both YAMLs (default.yaml and branch-specific config)
                    def config = defaultConfig + branchConfig

                    // Set environment variables for Terraform
                    config.each { key, value ->
                        env["TF_VAR_${key}"] = value
                    }
                    env["TF_VAR_branch"] = "${env.GIT_BRANCH}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    // Initialize Terraform and set up the state file in S3
                    def workspace = env.GIT_BRANCH
                    sh """
                    terraform init \
                        -backend-config="bucket=${S3_BUCKET}" \
                        -backend-config="key=${STATE_KEY_PREFIX}/terraform.tfstate" \
                        -backend-config="region=${AWS_REGION}"
                    terraform workspace select ${workspace} || terraform workspace new ${workspace}
                    """
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
