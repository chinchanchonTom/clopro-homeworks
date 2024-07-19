resource "yandex_vpc_route_table" "private-route" {
  name       = "route_private_subnet"
  network_id = yandex_vpc_network.netology_vpc.id

  static_route {
    destination_prefix =  var.destination_route
    next_hop_address   = var.nat_instance.nat.ip_address
  }
}