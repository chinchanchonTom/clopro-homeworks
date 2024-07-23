resource "yandex_lb_network_load_balancer" "lb-1" {
  name = var.lb.network.name

  listener {
    name = var.lb.network.listener_name
    port = var.lb.network.port
    external_address_spec {
      ip_version = var.lb.network.ip_version
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.group1.load_balancer.0.target_group_id

    healthcheck {
      name = var.lb.network.health_check_name
      http_options {
        port = var.lb.network.health_check_port
        path = var.lb.network.health_check_path
      }
    }
  }
}