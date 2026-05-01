terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}
resource "docker_network" "app_network" {
  name = "app-network"
}

provider "docker" {}
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  name  = "nginx-test"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }
  ports {
    internal = 80
    external = var.external_port
  }
  volumes {
    host_path = "/home/alex/Terraform/nginx/default.conf"
    container_path = "/etc/nginx/nginx.conf"
  }
}

resource "docker_image" "echo" {
  name = "hashicorp/http-echo"
}

resource "docker_container" "echo" {
  name  = "echo-test"
  image = docker_image.echo.image_id

  command = ["-text=hello from terraform"]

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 5678
    external = 5678
  }
}
