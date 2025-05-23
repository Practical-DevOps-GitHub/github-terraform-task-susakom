variable "create_develop_branch" {
  type    = bool
  default = true
}

variable "deploy_key_pub" {
  type    = string
  description = "Public deploy key for GitHub repo"
  sensitive   = true
}


variable "github_pat" {
  type        = string
  description = "GitHub Personal Access Token with repo, admin:org, project scopes"
  sensitive   = true
}
