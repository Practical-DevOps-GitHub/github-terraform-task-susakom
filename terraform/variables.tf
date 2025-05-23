variable "github_pat" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "create_develop_branch" {
  type    = bool
  default = true
}

variable "deploy_key_pub" {
  type    = string
  description = "Public deploy key for GitHub repo"
  sensitive   = true
}
