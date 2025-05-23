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

  default_branch = "develop"
}

# Получаем ID репозитория для защиты веток
data "github_repository" "existing_repo_data" {
  name = github_repository.existing_repo.name
}

# ==============================
# РЕСУРС: Защита ветки main
# ==============================
resource "github_branch_protection" "main_protection" {
  repository_id = data.github_repository.existing_repo_data.id
  pattern       = "main"

  required_pull_request_reviews {
    require_code_owner_reviews  = true
    required_approving_count    = 1
  }
}

# ==============================
# РЕСУРС: Защита ветки develop
# ==============================
resource "github_branch_protection" "develop_protection" {
  repository_id = data.github_repository.existing_repo_data.id
  pattern       = "develop"

  required_pull_request_reviews {
    require_code_owner_reviews  = false
    required_approving_count    = 2
  }
}

# ==============================
# РЕСУРС: Добавление пользователя в репозиторий
# ==============================
resource "github_repository_collaborator" "add_user" {
  repository = github_repository.existing_repo.name
  username   = "softservedata"
  permission = "admin"
}
