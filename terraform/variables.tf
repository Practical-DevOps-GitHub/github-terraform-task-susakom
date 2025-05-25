
variable "github_pat" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "deploy_key_pub" {
  type        = string
  description = "SSH public key for deploy access"
  sensitive   = true
}
