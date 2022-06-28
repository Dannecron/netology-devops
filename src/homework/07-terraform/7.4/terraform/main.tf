module "yc-vpc" {
  name = terraform.workspace
  source  = "git@github.com:hamnsk/terraform-yandex-vpc.git?ref=v0.5.0"
  create_folder = false
  yc_folder_id = var.YC_FOLDER_ID
  yc_cloud_id = var.YC_CLOUD_ID
  nat_instance = true
  subnets = [
    {
      zone           = var.YC_ZONE
      v4_cidr_blocks = ["192.168.10.0/24"]
    }
  ]
}

resource "yandex_compute_instance" "vm-1" {
  name = "test-vm-1"
  count = local.vm_count[terraform.workspace]

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32" # ubuntu-20-04-lts-v20210908
    }
  }

  network_interface {
    subnet_id = module.yc-vpc.subnets.0.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "internal_ip_address_vm_1" {
  value = [
    for vm in yandex_compute_instance.vm-1 : vm.network_interface.0.ip_address
  ]
}

output "external_ip_address_vm_1" {
  value = [
    for vm in yandex_compute_instance.vm-1 : vm.network_interface.0.nat_ip_address
  ]
}
