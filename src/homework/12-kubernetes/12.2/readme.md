Выполнение [домашнего задания](https://github.com/netology-code/devkub-homeworks/blob/main/12-kubernetes-02-commands.md)
по теме "12.2. Команды для работы с Kubernetes"

## Q/A

> Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
> После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

### Задание 1

> Запуск пода из образа в деплойменте
> 
> Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере.
> Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2).
> 
> Требования:
> * пример из hello world запущен в качестве deployment
> * количество реплик в deployment установлено в 2
> * наличие deployment можно проверить командой kubectl get deployment
> * наличие подов можно проверить командой kubectl get pods

Для начала необходимо описать спецификацию деплоймента: [hello_node_deployment.yml](./hello_node_deployment.yml).
Затем при помощи утилиты `kubectl` применить данную конфигурацию к кластеру:

```shell
kubectl apply -f hello_node_deployment.yml
```

После этого можно просмотреть информацию о деплойменте и подах:

```shell
kubectl get deployment
```

```text
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
hello-node-deployment   2/2     2            2           108s
```

```shell
kubectl get pods
```

```text
NAME                                     READY   STATUS    RESTARTS   AGE
hello-node-deployment-58c649b5df-dwvb2   1/1     Running   0          113s
hello-node-deployment-58c649b5df-mhsbm   1/1     Running   0          113s
```

### Задание 2

> Просмотр логов для разработки
> 
> Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе.
> Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.
> 
> Требования:
> * создан новый токен доступа для пользователя
> * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
> * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

Для достижения поставленной задачи необходимо:
* создать сервисный аккаунт
    ```shell
    kubectl create serviceaccount readonlyuser
    ```
* создать новую роль с доступами только на чтение данных подов:
    ```shell
    kubectl create clusterrole readonlyrole --verb=get --verb=list --verb=watch --resource=pods
    ```
* создать объект `rolebinding`:
    ```shell
    kubectl create clusterrolebinding readonlybinding --serviceaccount=default:readonlyuser --clusterrole=readonlyrole
    ```
* создать новый токен, используя спецификацию [serviceacc.yml](./serviceacc.yml)
    ```shell
    kubectl apply -f serviceacc.yml
    ```
* получить токен, который был создан на предыдущем шаге:
    ```shell
    TOKEN_NAME=$(kubectl describe serviceaccount readonlyuser | grep -i Tokens | awk '{print $2}')
    TOKEN_BASE64=$(kubectl get secret $TOKEN_NAME -o jsonpath='{.data.token}')
    TOKEN=$(echo $TOKEN_BASE64 | base64 --decode)
    ```
* добавить нового пользователя в конфигурацию `kubectl` вместе с токеном:
    ```shell
    kubectl config set-credentials developer --token=$TOKEN
    ```
* создать новый контекст для пользователя:
    ```shell
    kubectl config set-context podreader --cluster=minikube --user=developer
    ```

После этого можно переключиться на новый контекст и просмотреть все доступные команды:

```shell
kubectl config use-context podreader
```

```shell
kubectl auth can-i create pods
```

```text
no
```

```shell
kubectl auth can-i delete pods
```

```text
no
```

```shell
kubectl describe pod hello-node-deployment-58c649b5df-dwvb2
```

```text
Name:             hello-node-deployment-58c649b5df-dwvb2
Namespace:        default
<...>
```

```shell
kubectl logs hello-node-deployment-58c649b5df-dwvb2
```

// todo: forbidden

    

### Задание 3

> Изменение количества реплик
> 
> Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки.
> Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик.
> 
> Требования:
> * в deployment из задания 1 изменено количество реплик на 5
> * проверить что все поды перешли в статус running (kubectl get pods)

// todo
