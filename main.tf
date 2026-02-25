terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.60.1"
    }
    hetznerdns = {
      source = "germanbrew/hetznerdns"
      version = "3.5.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "hetznerdns" {
  api_token = var.hetznerdns_token
}

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "hetznerdns_token" {
  description = "Hetzner DNS API Token"
  type        = string
  sensitive   = true
}

variable "dns_zone" {
  description = "Hetzner DNS Zone"
  type        = string
}

variable "instance_type" {
  description = "Type of the instance to be created"
  type        = string
}

variable "operating_system" {
  description = "Operating system for the instance"
  type        = string
}

data "external" "ssh_key" {
  program = ["bash", "-c", "echo \"{\\\"output\\\": \\\"$(ssh-add -L | grep -E '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp)' | head -n 1)\\\"}\""]
}

resource "hcloud_ssh_key" "default" {
  name       = "default-ssh-key"
  public_key = data.external.ssh_key.result.output
}

resource "hcloud_primary_ip" "primary_ipv4" {
  name          = "primary_ipv4"
  type          = "ipv4"
  location      = "hel1"
  assignee_type = "server"
  auto_delete   = false
}

resource "hcloud_primary_ip" "primary_ipv6" {
  name          = "primary_ipv6"
  type          = "ipv6"
  location      = "hel1"
  assignee_type = "server"
  auto_delete   = false
}

resource "hetznerdns_zone" "zone" {
  name = var.dns_zone
  ttl  = 3600
}

resource "hetznerdns_record" "wildcard_ipv4" {
  zone_id = hetznerdns_zone.zone.id
  name    = "*"
  type    = "A"
  ttl     = 300
  value   = hcloud_primary_ip.primary_ipv4.ip_address
}

resource "hetznerdns_record" "wildcard_ipv6" {
  zone_id = hetznerdns_zone.zone.id
  name    = "*"
  type    = "AAAA"
  ttl     = 300
  value   = hcloud_primary_ip.primary_ipv6.ip_address
}

resource "hcloud_server" "server" {
  name        = "polkadot"
  server_type = var.instance_type
  image       = var.operating_system
  location    = "hel1"  
  ssh_keys    = [hcloud_ssh_key.default.name]

  public_net {
    ipv4_enabled = true
    ipv4 = hcloud_primary_ip.primary_ipv4.id
    ipv6_enabled = true
    ipv6 = hcloud_primary_ip.primary_ipv6.id
  }

  user_data = file("${path.module}/cloud-init.sh")
}

output "server_ipv4" {
  description = "The IPv4 address of the server"
  value       = hcloud_primary_ip.primary_ipv4.ip_address
}

output "server_ipv6" {
  description = "The IPv6 address of the server"
  value       = hcloud_primary_ip.primary_ipv6.ip_address
}
