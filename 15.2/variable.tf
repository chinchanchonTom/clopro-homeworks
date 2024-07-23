variable "cloud_id" {
  type        = string
  default     = " b1g5p48q6nv2v6hkeh4s"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gfqjnr717cnd3hdl42"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "storage" {
  type = map(object({
    sa_name          = string
    sa_role          = string
    bucket_name      = string
    bucket_size      = number
    acl              = string
  }))
  default = {
    bucket = {
      sa_name        = "tf-storage-sa"
      sa_role        = "admin"
      bucket_name    = "netologymaksim"
      bucket_size    = 1048576
      acl            = "public-read"
    }
  }
}

variable "instance_group" {
  type = map(object({
    vpc_name             = string
    subnet_name          = string
    cidr                 = list(string)
    zone                 = string
    instance_group_name  = string
    delete_protecton     = bool
    platform_id          = string
    memory               = number
    cores                = number 
    boot_disk_mode       = string
    image_id             = string
    boot_disk_size       = number
    network_settings     = string
    allocation_policy    = list(string)
    fixed_scale          = number
  }))
  default = {
    lamp = {
      vpc_name             = "lamp"
      subnet_name          = "lamp_subnet"
      cidr                 = ["192.168.10.0/24"]
      zone                 = "ru-central1-a"
      instance_group_name  = "lamp"
      delete_protecton     = false
      platform_id          = "standard-v1"
      memory               = 2
      cores                = 2 
      boot_disk_mode       = "READ_WRITE"
      image_id             = "fd827b91d99psvq5fjit"
      boot_disk_size       = 4
      network_settings     = "STANDARD"
      allocation_policy    = ["ru-central1-a"]
      fixed_scale          = 3
    }
  }
}

variable "lb" {
  type = map(object({
    name              = string
    listener_name     = string
    port              = number
    ip_version        = string
    health_check_name = string
    health_check_port = number
    health_check_path = string
  }))
  default = {
    network = {
      name              = "network-load-balancer-1"
      listener_name     = "network-load-balancer"
      port              = 80
      ip_version        = "ipv4"
      health_check_name = "http"
      health_check_port = 80
      health_check_path = "/index.html"
    }
  }
}