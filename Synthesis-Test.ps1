#cd C:\Projects\Synthesis\Test\Synthesis

aws configure


$connection_secret=aws secretsmanager list-secrets --region us-east-1 --filter Key="name",Values="synthesis-db-connection" --output text
if(!($connection_secret.Count -ge 0))
{
    terraform -chdir=terraform\secret_manager init
    terraform -chdir=terraform\secret_manager plan 
    terraform -chdir=terraform\secret_manager apply -auto-approve 
}


#terraform -chdir=terraform destroy -auto-approve 

terraform  -chdir=Terraform init
terraform -chdir=terraform plan 
terraform -chdir=terraform apply -auto-approve 
#terraform -chdir=terraform apply -auto-approve #DB_instance sometimes fails to create even after setting timeout
$terraform = & terraform -chdir=terraform output -json | ConvertFrom-Json 

#$tag = ":latest"
$repoUrl=$terraform.aws_ecr_repository_url.value 
$fullRepoUrl =$repoUrl #+$tag
$albURL=$terraform.aws_lb_staging_dns_name.value
$testURL=$albURL+"/api/jokes/random"
$name= "synthesis/home"
$cluster=$terraform.aws_ecs_cluster_name.value
$service=$terraform.aws_ecs_service_name.value

docker build -t $name -f Synthesis/Dockerfile Synthesis/..
docker tag $name  $fullRepoUrl
docker logout

#aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $repoUrl
aws ecr get-login-password | docker login --username AWS --password-stdin $repoUrl

docker push $repoUrl

aws ecs stop-task --region us-east-1 --cluster $cluster --task $(aws ecs list-tasks --region us-east-1 --cluster $cluster --service $service --output text --query taskArns[0])

Start-Sleep -Milliseconds 10000
[system.Diagnostics.Process]::Start("msedge",$testURL)