resource "yandex_vpc_network" "lamp" {
  name = var.instance_group.lamp.vpc_name
}

resource "yandex_vpc_subnet" "subnet_lamp" {
  name           = var.instance_group.lamp.subnet_name
  v4_cidr_blocks = var.instance_group.lamp.cidr
  zone           = var.instance_group.lamp.zone
  network_id     = yandex_vpc_network.lamp.id
}

resource "yandex_compute_instance_group" "group1" {
  name                = var.instance_group.lamp.instance_group_name
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.sa.id
  deletion_protection = var.instance_group.lamp.delete_protecton
  instance_template {
    platform_id = var.instance_group.lamp.platform_id
    resources {
      memory = var.instance_group.lamp.memory
      cores  = var.instance_group.lamp.cores
    }
    boot_disk {
      mode = var.instance_group.lamp.boot_disk_mode
      initialize_params {
        image_id = var.instance_group.lamp.image_id
        size     = var.instance_group.lamp.boot_disk_size
      }
    }
    network_interface {
      network_id = yandex_vpc_network.lamp.id
      subnet_ids = ["${yandex_vpc_subnet.subnet_lamp.id}"]
      nat        = true
    }
    metadata = {
      ssh-keys           = "ubuntu:${local.ssh_public_key}"
      user-data = data.template_file.cloudinit.rendered
    }
    network_settings {
      type = var.instance_group.lamp.network_settings
    }
  }

  scale_policy {
    fixed_scale {
      size = var.instance_group.lamp.fixed_scale
    }
  }

  allocation_policy {
    zones = var.instance_group.lamp.allocation_policy
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }

  health_check {
  interval = 5
  timeout = 2
  unhealthy_threshold = 2
  healthy_threshold = 2

  tcp_options {
    port = 80
  }
}

  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "Целевая группа Network Load Balancer"
  }

}

data template_file "cloudinit" {
  template =  file("cloud-init.yml")
}
