locals {
  vm_count = {
    stage = 1
    prod = 2
  }
  vm_2_config = {
    "balancer" = {
      cores = {
        stage = 1
        prod  = 2
      }
      memory = {
        stage = 1
        prod  = 2
      }

    }
    "application" = {
      cores = {
        stage = 1
        prod  = 2
      }
      memory = {
        stage = 1
        prod  = 2
      }

    }
  }
}
