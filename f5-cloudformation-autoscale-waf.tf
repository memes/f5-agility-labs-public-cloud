resource "aws_elb" "f5-autoscale-waf-elb" {
  name = "f5-autoscale-waf-elb-${var.emailidsan}"

  cross_zone_load_balancing = true
  security_groups           = ["${aws_security_group.elb.id}"]
  subnets                   = ["${aws_subnet.public-d.id}", "${aws_subnet.public-e.id}"]

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 8080
    instance_protocol  = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.elb_cert.arn}"
  }
}

resource "aws_cloudformation_stack" "f5-autoscaleWAF" {
  name         = "f5-autoscale-waf-${var.emailidsan}-${aws_vpc.terraform-vpc.id}"
  capabilities = ["CAPABILITY_IAM"]

  parameters {
    #DEPLOYMENT
    deploymentName           = "autoscale-waf-${var.emailidsan}"
    vpc                      = "${aws_vpc.terraform-vpc.id}"
    availabilityZones        = "us-east-1d, us-east-1e"
    subnets                  = "${aws_subnet.public-d.id}, ${aws_subnet.public-e.id}"
    restrictedSrcAddress     = "0.0.0.0/0"
    bigipElasticLoadBalancer = "${aws_elb.f5-autoscale-waf-elb.name}"

    #INSTANCE CONFIGURATION
    sshKey            = "${var.aws_keypair}"
    throughput        = "25Mbps"
    adminUsername     = "cluster-admin"
    managementGuiPort = 8443
    timezone          = "UTC"
    ntpServer         = "0.pool.ntp.org"

    #AUTO SCALING CONFIGURATION
    scalingMinSize          = "1"
    scalingMaxSize          = "2"
    scaleDownBytesThreshold = 10000
    scaleUpBytesThreshold   = 35000
    notificationEmail       = "${var.emailid}"

    #WAF VIRTUAL SERVICE CONFIGURATION
    virtualServicePort = 8080
    applicationPort    = 8080
    appInternalDnsName = "${aws_elb.example.dns_name}"
    policyLevel        = "low"

    #TAGS
    application = "f5app"
    environment = "f5env"
    group       = "f5group"
    owner       = "f5owner"
    costcenter  = "f5costcenter"
  }

  #CloudFormation templates triggered from Terraform must be hosted on AWS S3.
  template_url = "https://s3.amazonaws.com/f5-cft/f5-autoscale-bigip.template"
}
