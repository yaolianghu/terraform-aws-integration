# terraform-aws-integration
Terraform AWS Integration with EC2 + Lambda

Both Projects have JAVA code. 
1. Using Maven command to build JAVA code. "mvn clean install"
2. Using build_and_deploy.sh script to build jar file and run terraform.
3. Using destroy.sh script to destroy all the resources created in AWS.
4. *** You will need to create a PEM file within EC2 and replace the pem file name from variable file.


Project 1:
1. Create VPC VPC
2. Create Internet Gateway 
3. Create Custom Route Table 
4. Create a Subnet
5. Associate subnet with Route Table
6. Create Security Group to allow port 22, 80, 443
7. Create a network interface with an ip in the subnet. 
8. Assign an elastic IP to the network interface created in step 7
9. Create Linux EC2 server
10. Install JAVA 8 on EC2
11. Copy files over to the new EC2
12. Run the Rest API
13. Visit the API by http://{ec2-public-id}:8080/greeting?name=JOHN


Project 2:
1. Create Lambda 
2. Create API Gateway
3. Create IAM
4. Copy the jar file into Lambda
5. Visit the REST API by using API gateway link
