output "droplet_ip" {
  description = "Dirección IPv4 pública del droplet"
  value       = digitalocean_droplet.app.ipv4_address
}
