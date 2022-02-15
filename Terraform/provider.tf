provider "aws" {
  region = "us-east-1"
  #profile                 = "us_east_1"
  #profile                 = "synthesis"
}

# provider "aws" {
#    region                  = "us-east-1"
#   alias  = "us_east_1"
#   shared_config_files      = ["/Users/tf_user/.aws/config"]
#   shared_credentials_file = ["/Users/tf_user/.aws/credentials"]
#   profile                 = "us_east_1"

# }
provider "docker" {
    //version = "~> 2.7"
  host    = "npipe:////.//pipe//docker_engine"
}