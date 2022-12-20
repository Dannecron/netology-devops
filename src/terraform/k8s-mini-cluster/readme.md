## Cluster configuration

1. Авторизация в `yandex.cloud` (токен действует одни сутки)

    ```shell
    yc iam create-token 
    ```

2. Применение конфигурации `terraform`

    ```shell
    terraform apply
    ```

3. Конфигурация `kubespray`. Нужно заполнить `inventory.ini`: `control ansible_host` и `node1 ansible_host`.
  Так же нужно добавить в файле `group_vars/k8s_cluster/k8s_cluster.yml` значение в `supplementary_addresses_in_ssl_keys`
  ip-адрес control-ноды.  
4. Применение конфигурации `kubespray` (проходит довольно долго)

    ```shell
   ansible-playbook -u ubuntu -i inventory/mycluster/inventory.ini cluster.yml -b -v
    ```
5. Конфигурация `kubectl` на control-ноде

    ```shell
    ssh ubuntu@<control ansible_host>
    mkdir ~/.kube
    sudo cp /etc/kubernetes/admin.conf ~/.kube/config
    sudo chown ubuntu:ubuntu ~/.kube/config
    ```

6. Конфигурация `kubectl` на локальной машине

    ```shell
    scp ubuntu@<control ansible_host>:/home/ubuntu/.kube/config ~/.kube/kubespray-do.conf
    ```
   
    После этого нужно заменить ip-адрес `clusters.[0].cluster.server` с `127.0.0.1` на `control ansible_host`.
    
    В случае, если нужна постоянная конфигурация, то нужно переименовать файл `kubespray-do.conf` на `config`.
    Иначе, можно задать конфигурацию только для текущей сессии терминала:

    ```shell
    export KUBECONFIG=~/.kube/kubespray-do.conf
    ```
