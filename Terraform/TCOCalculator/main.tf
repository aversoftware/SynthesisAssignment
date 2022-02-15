terraform {
  required_version = ">= 0.12.6"

  required_providers {
    aws   = ">= 3"
    local = ">= 1"
  }
}

provider "aws" {
  region = "us-east-1"
}



module "pricing_state" {
  source = "../.terraform/modules/pricing"

  #  call_aws_pricing_api = false
  content = jsondecode(file(data.terraform_remote_state.local_state.config.path))
}

module "pricing_plan" {
  source = "../../modules/pricing"

  #  debug_output = true
  #  call_aws_pricing_api = false

  content = jsondecode(data.local_file.local_plan.content)

  resources = {
    "aws_instance.this#3" = { # 3 instances
      instanceType = "c5.xlarge"
      location     = "eu-west-2"
    }
    "aws_instance.this2" = {
      instanceType = "c4.xlarge"
      location     = "eu-west-1"
    }
  }
}

####################
# Calculation check
# ec2-all-together.tfstate and ec2-all-together-plan.json should produce the same cost estimation
# Disabled because I have not created plan and state for both set of "all-resources"
####################

#data "local_file" "all_together_state" {
#  filename = "../fixtures/ec2.terraform.tfstate"
#}
#
#module "pricing_all_together_state" {
#  source = "../../modules/pricing"
#
#  content = jsondecode(data.local_file.all_together_state.content)
#}

##################
# Terraform state
##################
data "terraform_remote_state" "local_state" {
  backend = "local"

  config = {
    path = "../terraform.tfstate"
  }
}

###########################
# Terraform plan (as JSON)
###########################
data "local_file" "local_plan" {
  filename = "../fixtures/all-resources/plan.json"
}