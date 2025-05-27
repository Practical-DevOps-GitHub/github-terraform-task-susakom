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
  owner     = "Practical-DevOps-GitHub" #  указываем нужную организацию
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

# ==============================
# РЕСУРС: Создание файла CODEOWNERS
# ==============================

resource "github_repository_file" "codeowners" {
  repository = data.github_repository.existing_repo.name
  branch     = "main"
  file       = ".github/CODEOWNERS"
    content        = <<EOF
* @softservedata
EOF
  commit_message = "Add CODEOWNERS file to main branch"
  overwrite_on_create = true
}

# ==============================
# РЕСУРС: Создание ветки develop 
# ==============================
resource "github_branch" "develop_branch" {
  repository= data.github_repository.existing_repo.name
  branch     = "develop"
  source_branch = "main"
}

# ==============================
# РЕСУРС: Создание файла pull_request_template.md
# ==============================
resource "github_repository_file" "pull_request_template" {
  repository = data.github_repository.existing_repo.name
  file       = ".github/pull_request_template.md"
  content        = <<EOF
### Describe your changes

### Issue ticket number and link

### Checklist before requesting a review
- [ ]  I have performed a self-review of my codeо
- [ ] If it is a core feature, I have added thorough tes
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOF
  branch         = "develop"
  commit_message = "Add pull_request_template to develop branch"
  depends_on = [github_branch.develop_branch]
}


# ==============================
# РЕСУРС: Защита ветки develop
# ==============================
resource "github_branch_protection" "develop_protection" {
 repository_id = data.github_repository.existing_repo.name
 pattern          = "develop"
 required_pull_request_reviews {
     require_code_owner_reviews  = false
     required_approving_review_count    = 2
}
  depends_on = [github_branch.develop_branch]
}

# ================================
# РЕСУРС: Указание ветки develop как ветки по умолчанию
# ================================

resource "github_branch_default" "default_develop" {
  repository = data.github_repository.existing_repo.name
  branch     = github_branch.develop_branch.branch
  depends_on = [github_branch.develop_branch]
}

# ================================
# РЕСУРС: Создание webhook для Discord
# ================================
resource "github_repository_webhook" "discord" {
  repository = data.github_repository.existing_repo.name

  configuration {
    url          = "https://discord.com/api/webhooks/1371418780156170290/kGb66wF5tigR-zVGhcsY2HFOc_2zzPc3pgLJMT81dMW6hMCx1sEkC-AY8sEQX0rVF9rX"
    content_type = "json"
  }

  events = ["pull_request"]
  active = true
}

# ================================
# РЕСУРС: Создание deploy_key secret
# ================================

resource "github_repository_deploy_key" "deploy_key" {
  repository = data.github_repository.existing_repo.name
  title      = "DEPLOY_KEY"
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj5doPA5fPI8+j21JGL9/j3F5b7shGX3Xlw4L+6rcWk deploy-key"
  read_only  = false
}
