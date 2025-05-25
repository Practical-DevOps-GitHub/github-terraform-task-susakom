
variable "gitnub_pat" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "deploy_key_pub" {
  type        = string
  description = "SSH public key for deploy access"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj5doPA5fPI8+j21JGL9/j3F5b7shGX3Xlw4L+6rcWk deploy-key"
  sensitive   = true
}
