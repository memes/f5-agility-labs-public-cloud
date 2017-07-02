resource "aws_cloudformation_stack" "f5-cluster" {
  name         = "f5-cluster-${var.emailidsan}-${aws_vpc.terraform-vpc.id}"
  capabilities = ["CAPABILITY_IAM"]

  parameters {
    Vpc                          = "${aws_vpc.terraform-vpc.id}"
    bigipExternalSecurityGroup   = "${aws_security_group.f5_data.id}"
    bigipManagementSecurityGroup = "${aws_security_group.f5_management.id}"
    imageName                    = "Best"
    instanceType                 = "t2.medium"
    licenseKey1                  = "${var.licenseKey1}"
    licenseKey2                  = "${var.licenseKey2}"
    managementSubnetAz1          = "${aws_subnet.f5-management-d.id}"
    managementSubnetAz2          = "${aws_subnet.f5-management-e.id}"
    restrictedSrcAddress         = "0.0.0.0/0"
    sshKey                       = "${var.aws_keypair}"
    subnet1Az1                   = "${aws_subnet.public-d.id}"
    subnet1Az2                   = "${aws_subnet.public-e.id}"
  }

  #CloudFormation templates triggered from Terraform must be hosted on AWS S3. Below is the temporary URL for testing.
  template_url = "https://s3.amazonaws.com/f5-cft/f5-existing-stack-across-az-cluster-byol-2nic-bigip.template"
}
