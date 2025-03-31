# terraform-ec2-infrastructure
An infrastructure containing two EC2 instances in different subnets, built using terraform.

This infrastructure contains
- One public and one private subnets in one AZ
- One public and one private subnets in another AZ
- One EC2 instance in each public subnet
- An RDS instace with a MySQL engine with all provate subents as its subnet group
- A web server security group that opens port 80 from anywhere
- An RDS security group that opens port 3306 to only web server's security group
- The name of the EC2 instances are from input variables "instance1_name" and "instance1_name"
- The ourput contains the public IP addresses of the EC2 instances and the endpoint of the RDS database
