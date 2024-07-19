resource "yandex_vpc_network" "netology_vpc" {
  name = "netology_vpc"
}

resource "yandex_vpc_subnet" "subnet_public" {
  name           = var.vpc_network.public.name
  v4_cidr_blocks = var.vpc_network.public.cidr
  zone           = var.vpc_network.public.zone
  network_id     = yandex_vpc_network.netology_vpc.id
}

resource "yandex_vpc_subnet" "subnet_private" {
  name           = var.vpc_network.private.name
  v4_cidr_blocks = var.vpc_network.private.cidr
  zone           = var.vpc_network.private.zone
  network_id     = yandex_vpc_network.netology_vpc.id
  route_table_id = yandex_vpc_route_table.private-route.id
}