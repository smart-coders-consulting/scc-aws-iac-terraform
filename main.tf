provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "main" {
  name         = "techi4sure.com"
  private_zone = false
}

# VPC MODULE

module "vpc" {
  source = "./modules/vpc"

  vpcs = {
    vpc1 = {
      name                = "nonprod-vpc"
      cidr_block          = "10.30.0.0/16"
      public_subnet_cidr  = "10.30.1.0/24"
      private_subnet_cidr = "10.30.2.0/24"
      az                  = "us-east-1a"
    }

    vpc2 = {
      name                = "prod-vpc"
      cidr_block          = "192.168.0.0/16"
      public_subnet_cidr  = "192.168.1.0/24"
      private_subnet_cidr = "192.168.2.0/24"
      az                  = "us-east-1b"
    }
  }
}

# SNS Module

module "sns" {
  source = "./modules/sns"

  topics = {
    stage = {
      name  = "stage-deployment-alerts"
      email = "nidhi@smartcodersconsulting.com"
    }
    prod = {
      name  = "prod-deployment-alerts"
      email = "nidhi@smartcodersconsulting.com"
    }
  }
}

# SECURITY GROUPS

module "sg" {
  source = "./modules/sg"

  security_groups = {

    nginx_nonprod = {
      name   = "nginx-sg-nonprod"
      vpc_id = module.vpc.vpc_ids["vpc1"]

      ingress = [
         {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc1"]]
        }
      ]
    }

    app_nonprod = {
      name   = "app-sg-nonprod"
      vpc_id = module.vpc.vpc_ids["vpc1"]

      ingress = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc1"]]
        },
        {
          from_port   = 4000
          to_port     = 4000
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc1"]]
        },
        {
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc1"]]
        },
        {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc1"]]
        },
        {
          from_port   = 27017
          to_port     = 27017
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc1"]]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

    nginx_prod = {
      name   = "nginx-sg-prod"
      vpc_id = module.vpc.vpc_ids["vpc2"]

      ingress = [
         {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc2"]]
        }
      ]
    }

    app_prod = {
      name   = "app-sg-prod"
      vpc_id = module.vpc.vpc_ids["vpc2"]

      ingress = [
        {
          from_port   = 4000
          to_port     = 4000
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc2"]]
        },
        {
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc2"]]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

    db_prod = {
      name   = "db-sg-prod"
      vpc_id = module.vpc.vpc_ids["vpc2"]

      ingress = [
        {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc2"]]
        },
        {
          from_port   = 27017
          to_port     = 27017
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc2"]]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

    jenkins_sg = {
      name   = "jenkins-sg"
      vpc_id = module.vpc.vpc_ids["vpc1"]

      ingress = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          cidr_blocks = [module.vpc.vpc_cidrs["vpc1"]]
        }
      ]

      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }

  depends_on = [module.vpc]
}


# APP EC2 (FIRST)

module "app_ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.small"

  instances = {

    dev-app-ec2 = {
      name                 = "dev-app-ec2"
      ami_id               = "ami-07b741c4fc321269b"
      subnet_id            = module.vpc.private_subnet_ids["vpc1"]
      public_ip_enabled    = false
      security_group_ids   = [module.sg.sg_ids["app_nonprod"]]
      iam_instance_profile = "blog-website-iam-role"
    }

    stage-app-ec2 = {
      name                 = "stage-app-ec2"
      ami_id               = "ami-0c234d76593c1db75"
      subnet_id            = module.vpc.private_subnet_ids["vpc1"]
      public_ip_enabled    = false
      security_group_ids   = [module.sg.sg_ids["app_nonprod"]]
      iam_instance_profile = "blog-website-iam-role"
    }

    prod-app-ec2 = {
      name                 = "prod-app-ec2"
      ami_id               = "ami-03cb4fe9cbf28884c"
      subnet_id            = module.vpc.private_subnet_ids["vpc2"]
      public_ip_enabled    = false
      security_group_ids   = [module.sg.sg_ids["app_prod"]]
      iam_instance_profile = "blog-website-iam-role"
    }
  }

  depends_on = [module.sg]
}

# PROD DB

module "prod_db_ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"

  instances = {
    prod-db-ec2 = {
      name                 = "prod-db-ec2"
      ami_id               = "ami-0e6c34bd009cd0e2c"
      subnet_id            = module.vpc.private_subnet_ids["vpc2"]
      public_ip_enabled    = false
      security_group_ids   = [module.sg.sg_ids["db_prod"]]
      iam_instance_profile = "blog-website-iam-role"
    }
  }

  depends_on = [module.sg]
}

# JENKINS EC2

module "jenkins_ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.small"

  instances = {
    jenkins-ec2 = {
      name                 = "jenkins-ec2"
      ami_id               = "ami-01cf2b434bbabc537"
      subnet_id            = module.vpc.private_subnet_ids["vpc1"]
      public_ip_enabled    = false
      security_group_ids   = [module.sg.sg_ids["jenkins_sg"]]
      iam_instance_profile = "blog-website-iam-role"
    }
  }

  depends_on = [module.sg]
}

# NGINX EC2 (USING SED)

module "nginx_ec2" {
  source        = "./modules/ec2"
  instance_type = "t3.micro"

  instances = {

    dev-nginx-ec2 = {
      name                 = "dev-nginx-ec2"
      ami_id               = "ami-0790830af6d683f61"
      subnet_id            = module.vpc.public_subnet_ids["vpc1"]
      public_ip_enabled    = true
      security_group_ids   = [module.sg.sg_ids["nginx_nonprod"]]
      iam_instance_profile = "blog-website-iam-role"

      user_data = <<-EOF
        #!/bin/bash
        sleep 20

        DEV_APP_IP=${module.app_ec2.all_ips["dev-app-ec2"].private_ip}
        JENKINS_IP=${module.jenkins_ec2.all_ips["jenkins-ec2"].private_ip}

        sed -i "s|HRMS_DEV_IP|$DEV_APP_IP|g" /etc/nginx/conf.d/hrms.conf
        sed -i "s|JENKINS_BACKEND_IP|$JENKINS_IP|g" /etc/nginx/conf.d/jenkins.conf

        nginx -t
        systemctl restart nginx
      EOF
    }

    stage-nginx-ec2 = {
      name                 = "stage-nginx-ec2"
      ami_id               = "ami-03580774d1e6a2fbc"
      subnet_id            = module.vpc.public_subnet_ids["vpc1"]
      public_ip_enabled    = true
      security_group_ids   = [module.sg.sg_ids["nginx_nonprod"]]
      iam_instance_profile = "blog-website-iam-role"

      user_data = <<-EOF
        #!/bin/bash
        sleep 20

        STAGE_APP_IP=${module.app_ec2.all_ips["stage-app-ec2"].private_ip}

        sed -i "s|HRMS_STAGE_IP|$STAGE_APP_IP|g" /etc/nginx/conf.d/hrms.conf

        nginx -t
        systemctl restart nginx
      EOF
    }

    prod-nginx-ec2 = {
      name                 = "prod-nginx-ec2"
      ami_id               = "ami-026372737abc01041"
      subnet_id            = module.vpc.public_subnet_ids["vpc2"]
      public_ip_enabled    = true
      security_group_ids   = [module.sg.sg_ids["nginx_prod"]]
      iam_instance_profile = "blog-website-iam-role"

      user_data = <<-EOF
        #!/bin/bash
        sleep 20

        PROD_APP_IP=${module.app_ec2.all_ips["prod-app-ec2"].private_ip}

        sed -i "s|HRMS_PROD_IP|$PROD_APP_IP|g" /etc/nginx/conf.d/hrms.conf

        nginx -t
        systemctl restart nginx
      EOF
    }
  }

  depends_on = [
    module.app_ec2,
    module.jenkins_ec2
  ]
}

resource "aws_secretsmanager_secret" "ec2_ips" {
  name        = "ec2/public_ips"
  description = "All EC2 public and private IPs"
}

resource "aws_secretsmanager_secret_version" "ec2_ips_version" {
  secret_id = aws_secretsmanager_secret.ec2_ips.id

  secret_string = jsonencode(
    merge(

      # APP EC2 (PRIVATE ONLY)

      {
        for k, v in module.app_ec2.all_ips :
        "${k}_private" => v.private_ip
      },

      # JENKINS EC2 (PRIVATE ONLY)

      {
        for k, v in module.jenkins_ec2.all_ips :
        "${k}_private" => v.private_ip
      },

      # PROD DB EC2 (PRIVATE ONLY)

      {
        for k, v in module.prod_db_ec2.all_ips :
        "${k}_private" => v.private_ip
      },

      # NGINX EC2 (PRIVATE)
      {
        for k, v in module.nginx_ec2.all_ips :
        "${k}_private" => v.private_ip
      },

      # NGINX EC2 (PUBLIC — ONLY IF EXISTS)

      {
        for k, v in module.nginx_ec2.all_ips :
        "${k}_public" => v.public_ip
        if v.public_ip != null
      }
    )
  )
}

# -----------------------------
# ROUTE53 RECORDS (AUTO UPDATE)
# -----------------------------

resource "aws_route53_record" "dev" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "dev-hr.techi4sure.com"
  type    = "A"
  ttl     = 300

  records = [
    module.nginx_ec2.all_ips["dev-nginx-ec2"].public_ip
  ]
}

resource "aws_route53_record" "stage" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "stage-hr.techi4sure.com"
  type    = "A"
  ttl     = 300

  records = [
    module.nginx_ec2.all_ips["stage-nginx-ec2"].public_ip
  ]
}

# resource "aws_route53_record" "prod" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "hr.techi4sure.com"
#   type    = "A"
#   ttl     = 300

#   records = [
#     module.nginx_ec2.all_ips["prod-nginx-ec2"].public_ip
#   ]
# }