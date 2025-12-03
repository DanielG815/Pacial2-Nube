terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "digitalocean" {
  token = var.do_token != "" ? var.do_token : (try(env.DIGITALOCEAN_TOKEN, ""))
}

resource "digitalocean_droplet" "app" {
  name   = var.droplet_name
  region = var.region
  size   = var.size
  image  = var.image
  ssh_keys = var.ssh_fingerprint != "" ? [var.ssh_fingerprint] : []

  user_data = templatefile("${path.module}/cloud-init.tpl", { repo_url = var.repo_url, branch = var.repo_branch })

  tags = ["notes-app"]
}

output "droplet_ip" {
  description = "Dirección IPv4 pública del droplet"
  value       = digitalocean_droplet.app.ipv4_address
}
