resource "digitalocean_droplet" "k8s" {
  count              = 3
  image              = "ubuntu-18-04-x64"
  name               = "k8s-${count.index}"
  region             = "nyc3"
  size               = "s-4vcpu-8gb"
  monitoring         = true
  private_networking = true
  ssh_keys = [
    data.digitalocean_ssh_key.ubuntu.id
  ]
  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }
  user_data = file("${path.module}/${local.user-data}")
}