variable "github_pat" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "create_develop_branch" {
  type    = bool
  default = true
}
