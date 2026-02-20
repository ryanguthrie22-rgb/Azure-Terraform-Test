# Terraform Azure Baseline

Creates:
- Resource Group
- VNet + Subnet
- NSG + SSH rule restricted to a CIDR
- Storage Account (Standard/LRS) for boot diagnostics
- Linux VM

## Run
From env/dev:
terraform init
terraform apply

## Notes
- Do NOT commit terraform.tfstate or terraform.tfvars
- Use terraform.tfvars.example as a template
