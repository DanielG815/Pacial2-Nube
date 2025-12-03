variable "do_token" {
  type    = string
  default = ""
  description = "Token de DigitalOcean (se puede pasar por env var DIGITALOCEAN_TOKEN)"
}

variable "ssh_fingerprint" {
  type    = string
  default = ""
  description = "Fingerprint / id de la clave SSH registrada en DigitalOcean (opcional)"
}

variable "droplet_name" {
  type    = string
  default = "notes-droplet"
}

variable "region" {
  type    = string
  default = "nyc3"
}

variable "size" {
  type    = string
  default = "s-1vcpu-1gb"
}

variable "image" {
  type    = string
  default = "ubuntu-22-04-x64"
}

variable "repo_url" {
  type    = string
  default = "https://github.com/DanielG815/Pacial2-Nube.git"
}

variable "repo_branch" {
  type    = string
  default = "main"
}
