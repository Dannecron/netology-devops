Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/12-kubernetes-05-cni.md)
по теме "12.5. Сетевые решения CNI"

## Q/A

> После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.

### Задание 1

> Установить в кластер CNI плагин Calico
> 
> Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования:
> * установка производится через ansible/kubespray;
> * после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

Значение текущего используемого сетевого плагина для кластера, развёрнутого через `kubespray`
можно посмотреть в inventory-файле `mycluster/group_vars/k8s_cluster/k8s-cluster.yml`.
А именно - это значение ключа `kube_network_plugin`. По умолчанию задан `calico`, поэтому никаких изменений в конфигурацию вносить не нужно.

Для тестирования создадим в кластере сервис [frontend](./config/frontend.yml):

```shell
kubectl apply -f frontend.yml
```

Предполагается, что необходимо настроить политику доступа из-вне для сервиса `frontend`.
Для этого необходимо создать спецификацию `NetworkPolicy`: [frontend-policy.yml](./config/frontend-policy.yml),
которая говорит о том, что доступ разрешён со всех ресурсов, но только к портам `80` и `443`.

```shell
kubectl apply -f frontend-policy.yml
```

### Задание 2

> Изучить, что запущено по умолчанию.
> 
> Самый простой способ — проверить командой calicoctl get <type>.
> Для проверки стоит получить список нод, ipPool и profile.
> Требования: 
> * установить утилиту calicoctl
> * получить 3 вышеописанных типа в консоли.

Для установки утилиты необходимо выполнить следующие команды:

```shell
curl -L https://github.com/projectcalico/calico/releases/download/v3.24.5/calicoctl-linux-amd64 -o calicoctl
chmod +x ./calicoctl
sudo mv calicoctl /usr/local/bin/
```

Для проверки установки:

```shell
calicoctl version
```

```text
Client Version:    v3.24.5
Git commit:        f1a1611ac
Cluster Version:   v3.23.3
Cluster Type:      kubespray,kubeadm,kdd
```

Следующим шагом необходимо получить информацию о сущностях кластера:

* ноды:

    ```shell
    calicoctl get node --allow-version-mismatch
    ```
    
    ```text
    NAME
    control
    node1
    ```

* ipPools:

    ```shell
    calicoctl get ipPool --allow-version-mismatch
    ```
    
    ```text
    NAME           CIDR             SELECTOR
    default-pool   10.233.64.0/18   all()
    ```

* profile:

    ```shell
    calicoctl get profile --allow-version-mismatch
    ```
    
    ```text
    NAME
    projectcalico-default-allow
    kns.default
    kns.kube-node-lease
    kns.kube-public
    kns.kube-system
    ksa.default.default
    ksa.kube-node-lease.default
    ksa.kube-public.default
    ksa.kube-system.attachdetach-controller
    ksa.kube-system.bootstrap-signer
    ksa.kube-system.calico-node
    ksa.kube-system.certificate-controller
    ksa.kube-system.clusterrole-aggregation-controller
    ksa.kube-system.coredns
    ksa.kube-system.cronjob-controller
    ksa.kube-system.daemon-set-controller
    ksa.kube-system.default
    ksa.kube-system.deployment-controller
    ksa.kube-system.disruption-controller
    ksa.kube-system.dns-autoscaler
    ksa.kube-system.endpoint-controller
    ksa.kube-system.endpointslice-controller
    ksa.kube-system.endpointslicemirroring-controller
    ksa.kube-system.ephemeral-volume-controller
    ksa.kube-system.expand-controller
    ksa.kube-system.generic-garbage-collector
    ksa.kube-system.horizontal-pod-autoscaler
    ksa.kube-system.job-controller
    ksa.kube-system.kube-proxy
    ksa.kube-system.namespace-controller
    ksa.kube-system.node-controller
    ksa.kube-system.nodelocaldns
    ksa.kube-system.persistent-volume-binder
    ksa.kube-system.pod-garbage-collector
    ksa.kube-system.pv-protection-controller
    ksa.kube-system.pvc-protection-controller
    ksa.kube-system.replicaset-controller
    ksa.kube-system.replication-controller
    ksa.kube-system.resourcequota-controller
    ksa.kube-system.root-ca-cert-publisher
    ksa.kube-system.service-account-controller
    ksa.kube-system.service-controller
    ksa.kube-system.statefulset-controller
    ksa.kube-system.token-cleaner
    ksa.kube-system.ttl-after-finished-controller
    ksa.kube-system.ttl-controller
    ```
