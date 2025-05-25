terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token     = var.github_pat
  owner     = "Practical-DevOps-GitHub" # ⇨ Здесь указываем нужную организацию
}

# ==============================
# РЕСУРС: Управление существующим репозиторием
# ==============================
data "github_repository" "existing_repo" {
  full_name = "Practical-DevOps-GitHub/github-terraform-task-susakom"
}

# ==============================
# РЕСУРС: Добавление пользователя в репозиторий
# ==============================
resource "github_repository_collaborator" "add_user" {
  repository       = data.github_repository.existing_repo.name
  username         = "softservedata"
  permission = "admin"
}


# ==============================
# РЕСУРС: Защита ветки main
# ==============================
resource "github_branch_protection" "main_protection" {
  repository_id = data.github_repository.existing_repo.name
  pattern       = "main"
  
  enforce_admins = true

  required_pull_request_reviews {
   require_code_owner_reviews        = true  
    required_approving_review_count   = 1
  }
  depends_on = [github_repository_collaborator.add_user]
}

resource "github_repository_file" "codeowners" {
  repository = data.github_repository.existing_repo.name
  branch     = "main"
  file       = ".github/CODEOWNERS"
  content    = "* @softservedata"
  overwrite_on_create = true
  
 }


# ==============================
# РЕСУРС: Сохраняем Discord Webhook как секрет
# ==============================
resource "github_actions_secret" "discord_webhook" {
  repository      = data.github_repository.existing_repo.name
  secret_name     = "DISCORD_WEBHOOK_URL"
  plaintext_value = "https://discord.com/api/webhooks/1371418780156170290/kGb66wF5tigR-zVGhcsY2HFOc_2zzPc3pgLJMT81dMW6hMCx1sEkC-AY8sEQX0rVF9rX   "
}

resource "github_repository_file" "pull_request_template" {
  repository = data.github_repository.existing_repo.name
  file       = ".github/pull_request_template.md"
  content    = "### Describe your changes\n\n<!-- Please describe what you've changed -->\n\n---\n\n### Issue ticket number and link\n\n<!-- For example: Closes #123 or https://github.com/your/repo/issues/123     -->\n\n---\n\n### Checklist before requesting a review\n\n- [ ] I have performed a self-review of my code\n- [ ] If it is a core feature, I have added thorough tests\n- [ ] Do we need to implement analytics?\n- [ ] Will this be part of a product update?\n<!-- If yes, please write one phrase about this update -->"
  branch     = "main"
}

# ==============================
# РЕСУРС: Добавляем GitHub Action для уведомлений в Discord
# ==============================
resource "github_repository_file" "discord_pr_notifier" {
  repository = data.github_repository.existing_repo.name
  file       = ".github/workflows/pull_request_discord_notify.yml"
  content    =  base64encode(file("${path.module}/templates/pull_request_discord_notify.md"))
  branch     = "main"
  depends_on = [github_repository_file.pull_request_template]
}



# ==============================
# Остальные ресурсы временно закомментированы
# чтобы сосредоточиться на защите ветки main
# ==============================

/* 

# ==============================
# РЕСУРС: Создание ветки develop 
# ==============================
resource "github_branch" "develop_branch" {
  repository= data.github_repository.existing_repo.name
  branch     = "develop"
  source_branch = "main"
}

resource "github_branch_default" "default_develop" {
  repository = data.github_repository.existing_repo.name
  branch     = github_branch.develop_branch.branch
  depends_on = [github_branch.develop_branch]
}

# ==============================
# РЕСУРС: Защита ветки develop
# ==============================
resource "github_branch_protection" "develop_protection" {
  repository_id = data.github_repository.existing_repo.id
  pattern          = "develop"
  required_pull_request_reviews {
    require_code_owner_reviews  = false
    required_approving_review_count    = 2
  }
  depends_on = [github_branch.develop_branch]
}

# ==============================
# РЕСУРС: Добавление секрета TERRAFORM
# ==============================
resource "github_actions_secret" "terraform_code" {
  repository      = data.github_repository.existing_repo.name
  secret_name     = "TERRAFORM"
  plaintext_value = file("${path.module}/main.tf")
}

resource "github_repository_file" "pull_request_template" {
  repository = data.github_repository.existing_repo.name
  file       = ".github/pull_request_template.md"
  content    = "### Describe your changes\n\n<!-- Please describe what you've changed -->\n\n---\n\n### Issue ticket number and link\n\n<!-- For example: Closes #123 or https://github.com/your/repo/issues/123     -->\n\n---\n\n### Checklist before requesting a review\n\n- [ ] I have performed a self-review of my code\n- [ ] If it is a core feature, I have added thorough tests\n- [ ] Do we need to implement analytics?\n- [ ] Will this be part of a product update?\n<!-- If yes, please write one phrase about this update -->"
  branch     = "main"
}


# ==============================
# РЕСУРС: Добавление Deploy Key
# ==============================
resource "github_repository_deploy_key" "deploy_key" {
  repository = data.github_repository.existing_repo.name
  title      = "DEPLOY_KEY"
  key        = var.deploy_key_pub
  read_only  = false
}

# ==============================
# РЕСУРС: Добавляем GitHub Action для уведомлений в Discord
# ==============================
resource "github_repository_file" "discord_pr_notifier" {
  repository = data.github_repository.existing_repo.name
  file       = ".github/workflows/pull_request_discord_notify.yml"
  content    = file("${path.module}/templates/pull_request_discord_notify.yml")
  branch     = "main"
}


*/


output "repo_info" {
  value = data.github_repository.existing_repo
}
