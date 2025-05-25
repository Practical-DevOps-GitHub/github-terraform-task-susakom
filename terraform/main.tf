# Добавляем провайдер local
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Создаём копию main.tf как локальный файл
resource "local_file" "main_tf_copy" {
  content  = <<EOT
# Сюда будет записано содержимое вашего main.tf



variable "github_pat" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "deploy_key_pub" {
  type        = string
  description = "Public SSH key for GitHub deploy access"
  sensitive   = true
}

provider "github" {
  token = var.github_pat
  owner = "Practical-DevOps-GitHub"
}

data "github_repository" "existing_repo" {
  full_name = "Practical-DevOps-GitHub/github-terraform-task-susakom"
}

# ... остальные ресурсы ...

EOT
  filename = "${path.module}/temp_secret/main.tf"
}

# Сохраняем содержимое как GitHub Secret
resource "github_actions_secret" "terraform_code" {
  repository      = data.github_repository.existing_repo.name
  secret_name     = "TERRAFORM"
  plaintext_value = local_file.main_tf_copy.content
}
