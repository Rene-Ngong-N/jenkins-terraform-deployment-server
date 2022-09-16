# create-jenkins-on-aws-terraform

Instructions to create jenkins server in AWS using Terraform

1)   Create a folder called “jenkins_terra” 
2)   Navigate to the folder created in 1) above
3)   Clone from the repo:  
    
4)   Goto your aws console and create a key pair named ‘prud-key’
5)   Download the pem file in 4) above 
6)   Open the Terraform project checked out in 3) above in Visual Code
7)   Copy the content of your new pem file and replace the content of 	‘prud-key.pem’	file in the project
8)   Note that the jenkins server is set up to run in us-west-1. You can alter     	the region in the Provider block in “main.tf” to suit your conditions
9)   It is assumed that you have already installed Terraform
10) Run Terraform init, plan and apply
11) If successful, the public IP (public_IP) will be displayed as output
12) Goto the browser and enter http://{public_IP}:8080
13) You can now configure your Jenkins
14) To SSH to your jenkins server, navigate to the location of your .pem file and enter:        	ssh -i "prud-key.pem" ec2-user@{public_IP}
