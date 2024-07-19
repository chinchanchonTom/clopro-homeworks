# Домашнее задание к занятию «Организация сети»

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию). 
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории. 
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашнее задание по теме «Облачные провайдеры и синтаксис Terraform». Заранее выберите регион (в случае AWS) и зону.

---
### Задание 1. Yandex Cloud 

**Что нужно сделать**

![test](https://github.com/chinchanchonTom/clopro-homeworks/blob/main/15.1/img/Screenshot_1.png)  



1. Создать пустую VPC. Выбрать зону.

```
resource "yandex_vpc_network" "netology_vpc" {
  name = "netology_vpc"
}

```

2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
```
resource "yandex_vpc_subnet" "subnet_public" {
  name           = var.vpc_network.public.name
  v4_cidr_blocks = var.vpc_network.public.cidr
  zone           = var.vpc_network.public.zone
  network_id     = yandex_vpc_network.netology_vpc.id
}

```

 - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.

```
resource "yandex_compute_instance" "nat_instance" {
    name = var.nat_instance.nat.name
    zone = var.nat_instance.nat.zone
    platform_id = var.nat_instance.nat.platform_id

    resources {
        cores  = var.nat_instance.nat.cores
        memory = var.nat_instance.nat.memory
    }
  
  boot_disk {
    initialize_params {
      image_id = var.nat_instance.nat.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_public.id
    nat       = var.nat_instance.nat.nat_enable
    ip_address = var.nat_instance.nat.ip_address 
  }
}

```

 - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.
![test](https://github.com/chinchanchonTom/clopro-homeworks/blob/main/15.1/img/Screenshot_7.png)  
[test](add screen)   

3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
```
resource "yandex_vpc_subnet" "subnet_private" {
  name           = var.vpc_network.private.name
  v4_cidr_blocks = var.vpc_network.private.cidr
  zone           = var.vpc_network.private.zone
  network_id     = yandex_vpc_network.netology_vpc.id
  route_table_id = yandex_vpc_route_table.private-route.id
}
```
![test](https://github.com/chinchanchonTom/clopro-homeworks/blob/main/15.1/img/Screenshot_4.png)  


 - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.

```
resource "yandex_vpc_route_table" "private-route" {
  name       = "route_private_subnet"
  network_id = yandex_vpc_network.netology_vpc.id

  static_route {
    destination_prefix =  var.destination_route
    next_hop_address   = var.nat_instance.nat.ip_address
  }
}
```
![test](https://github.com/chinchanchonTom/clopro-homeworks/blob/main/15.1/img/Screenshot_6.png)  


 - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.
```
resource "yandex_compute_instance" "private" {
  name         = var.vm.private_vm.name
  zone         = var.vm.private_vm.zone
  platform_id  = var.vm.private_vm.platform_id
  resources {
    cores  = var.vm.private_vm.cores
    memory = var.vm.private_vm.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.subnet_private.id
    nat            = var.vm.private_vm.nat_enable
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${local.ssh_public_key}"
  }
}

```

![test](https://github.com/chinchanchonTom/clopro-homeworks/blob/main/15.1/img/Screenshot_7.png)  
![test](https://github.com/chinchanchonTom/clopro-homeworks/blob/main/15.1/img/Screenshot_5.png)  
![test](https://github.com/chinchanchonTom/clopro-homeworks/blob/main/15.1/img/Screenshot_8.png)  

Resource Terraform для Yandex Cloud:

- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

---
### Задание 2. AWS* (задание со звёздочкой)

Это необязательное задание. Его выполнение не влияет на получение зачёта по домашней работе.

**Что нужно сделать**

1. Создать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 10.10.1.0/24.
 - Разрешить в этой subnet присвоение public IP по-умолчанию.
 - Создать Internet gateway.
 - Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
 - Создать security group с разрешающими правилами на SSH и ICMP. Привязать эту security group на все, создаваемые в этом ДЗ, виртуалки.
 - Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться, что есть доступ к интернету.
 - Добавить NAT gateway в public subnet.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 10.10.2.0/24.
 - Создать отдельную таблицу маршрутизации и привязать её к private подсети.
 - Добавить Route, направляющий весь исходящий трафик private сети в NAT.
 - Создать виртуалку в приватной сети.
 - Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети, и убедиться, что с виртуалки есть выход в интернет.

Resource Terraform:

1. [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc).
1. [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet).
1. [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway).

### Правила приёма работы

Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
