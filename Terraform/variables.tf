variable "applicationName" {
  type = string
  default = "Synthesis"
}

variable "region" {
  type = string
  default = "us-east-1"
}


locals { 
  account_id = data.aws_caller_identity.current.account_id
  region = "eu-east-1"
  tags = {
    Owner       = "Maurice"
    Environment = "dev"
    Product     = "Synthesis"
  }
  repo = "synthesis/home"
  applicationName="Synthesis"
  db_password = "${sha256(bcrypt(random_string.password.result))}"
  db_username = "admin"
}


resource "random_string" "password" {
 length = 16
 special = true
}



variable "timeouts" {
  description = "nested block: NestingSingle, min items: 0, max items: 0"
  type = set(object(
    {
      create = string
      delete = string
      update = string
    }
  ))

  default = []

}