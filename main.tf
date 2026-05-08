terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
resource "docker_network" "app_network" {
  name = "app-network"
}

locals {
  backend_container_names = [
    for container in docker_container.echo :
    container.name
  ]
}

resource "docker_image" "echo" {
  name = "hashicorp/http-echo"
}

resource "docker_container" "echo" {
  count = var.backend_count
  name  = "echo-${count.index}"
  image = docker_image.echo.image_id

  command = ["-text=hello from echo-${count.index}"]

  networks_advanced {
    name = docker_network.app_network.name
  }
}

resource "local_file" "nginx_config" {
  content = templatefile(
    "${path.module}/templates/nginx.conf.tftpl",
    {
      backend_containers = local.backend_container_names
    }
  )

  filename = "${path.module}/nginx/default.conf"
}

provider "docker" {}
resource "docker_image" "nginx" {
  name = "nginx:latest"
  depends_on = [local_file.nginx_config]
}

resource "docker_container" "nginx" {
  name  = "nginx"
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
    container_path = "/etc/nginx/conf.d/default.conf"
  }

}
