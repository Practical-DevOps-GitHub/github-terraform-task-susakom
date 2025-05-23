
# ==============================
# РЕСУРС: Управление существующим репозиторием
# ==============================
resource "github_repository" "existing_repo" {
  name        = "github-terraform-task-susakom"
  description = "Управляемый через Terraform"
  visibility  = "public"
  has_issues  = true
  has_projects = false
  has_wiki     = false

  # Указываем, что default ветка — develop
  default_branch = "develop"
}

# ==============================
# РЕСУРС: Создание ветки develop (условное, если ветка существует данная часть пропуститься)
# ==============================
resource "github_branch" "develop_branch" {
  count = var.create_develop_branch ? 1 : 0

  repository = github_repository.existing_repo.name
  branch     = "develop"
}



# ==============================
# РЕСУРС: Защита ветки main
# ==============================
resource "github_branch_protection" "main_protection" {
  repository      = github_repository.existing_repo.name
  branch          = "main"


  required_pull_request_review {
    require_code_owner_reviews  = true   # требуется апрув от владельца
    required_approving_count    = 1
  }
}

# ==============================
# РЕСУРС: Защита ветки develop
# ==============================
resource "github_branch_protection" "develop_protection" {
  repository      = github_repository.existing_repo.name
  branch          = "develop"


  required_pull_request_review {
    require_code_owner_reviews  = false
    required_approving_count    = 2
  }
}

# ==============================
# РЕСУРС: Добавление секрета TERRAFORM
# ==============================
resource "github_actions_secret" "terraform_code" {
  repository      = github_repository.existing_repo.name
  secret_name     = "TERRAFORM"
  plaintext_value = file("${path.module}/main.tf")
}

# ==============================
# РЕСУРС: Добавление пользователя в репозиторий
# ==============================
resource "github_repository_collaborator" "add_user" {
  repository       = github_repository.existing_repo.name
  username         = "softservedata"
  permission_level = "admin"
}

# ==============================
# РЕСУРС: Добавление файла CODEOWNERS
# ==============================
resource "github_repository_file" "codeowners" {
  repository = github_repository.existing_repo.name
  file       = ".github/CODEOWNERS"
  content    = base64encode("* @softservedata")
  branch     = "main"
}
resource "github_repository_file" "pull_request_template" {
  repository = github_repository.existing_repo.name
  file       = ".github/pull_request_template.md"
  content    = base64encode("### Describe your changes\n\n<!-- Please describe what you've changed -->\n\n---\n\n### Issue ticket number and link\n\n<!-- For example: Closes #123 or https://github.com/your/repo/issues/123  -->\n\n---\n\n### Checklist before requesting a review\n\n- [ ] I have performed a self-review of my code\n- [ ] If it is a core feature, I have added thorough tests\n- [ ] Do we need to implement analytics?\n- [ ] Will this be part of a product update?\n<!-- If yes, please write one phrase about this update -->")
  branch     = "develop"
}


# ==============================
# РЕСУРС: Добавление Deploy Key
# ==============================
resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.existing_repo.name
  title      = "DEPLOY_KEY"
  key        = file("~/.ssh/DEPLOY_KEY.pub")
  read_only  = false # true = только чтение, false = разрешить запись
}

# ==============================
# РЕСУРС: Сохраняем Discord Webhook как секрет
# ==============================
resource "github_actions_secret" "discord_webhook" {
  repository      = github_repository.existing_repo.name
  secret_name     = "DISCORD_WEBHOOK_URL"
  plaintext_value = "https://discord.com/api/webhooks/1371418780156170290/kGb66wF5tigR-zVGhcsY2HFOc_2zzPc3pgLJMT81dMW6hMCx1sEkC-AY8sEQX0rVF9rX"
}

# ==============================
# РЕСУРС: Добавляем GitHub Action для уведомлений в Discord
# ==============================
resource "github_repository_file" "discord_pr_notifier" {
  repository = github_repository.existing_repo.name
  file       = ".github/workflows/pull_request_discord_notify.yml"
  content    = base64encode(file("${path.module}/templates/pull_request_discord_notify.yml"))
  branch     = "main"
}
