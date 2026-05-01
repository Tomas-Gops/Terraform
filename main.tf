terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  name  = "nginx-test"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.external_port
  }
  volumes {
    host_path      = "${path.module}/nginx/default.conf"
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

  ports {
    internal = 5678
    external = 5678
  }
}
