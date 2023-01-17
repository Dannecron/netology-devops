Выполнение [домашнего задания](https://github.com/netology-code/clokub-homeworks/blob/clokub-5/14.5.md)
по теме "14.5. SecurityContext, NetworkPolicies"

## Q/A

### Задача 1

> Рассмотрите пример [config/example-security-context.yml](./config/example-security-context.yml)

> Создайте модуль
> ```shell
> kubectl apply -f config/example-security-context.yml
> ```

```text
pod/security-context-demo created
```

> Проверьте установленные настройки внутри контейнера
> 
> ```shell
> kubectl logs security-context-demo
> ```

```text
uid=1000 gid=3000 groups=3000
```

### Задание 2

> Рассмотрите пример [config/example-network-policy.yml](./config/example-network-policy.yml).
> 
> Создайте два модуля. Для первого модуля разрешите доступ к внешнему миру и ко второму контейнеру.
> Для второго модуля разрешите связь только с первым контейнером. Проверьте корректность настроек.

Создание подов и правил для второго пода описаны в конфигурации [config/restricted-pods.yml](./config/restricted-pods.yml).

Необходимо применить данный конфиг:

```shell
kubectl apply -f config/restricted-pods.yml
```

```text
pod/test-pod-outer created
pod/test-pod-inner created
networkpolicy.networking.k8s.io/test-network-policy-inner created
```

Проверить, что поды успешно создались:

```shell
kubectl get pod
```

```text
NAME             READY   STATUS    RESTARTS   AGE
test-pod-inner   1/1     Running   0          59s
test-pod-outer   1/1     Running   0          59s
```

Затем необходимо проверить, что из контейнера пода `test-pod-outer` доступен как внешние ресурсы (например, `google.com`),
так и контейнер пода `test-pod-inner`. IP-адрес контейнера необходимо получить заранее, например,
через выполнение команды `kubectl describe pod test-pod-inner`.

```shell
kubectl exec -it pods/test-pod-inner -- sh
curl -sS -D - -o /dev/null https://google.com
curl -sS -D - -o /dev/null http://10.233.102.132
```

```text
HTTP/2 301
<...>

HTTP/1.1 200 OK
<...>
```

Следующим шагом необходимо проверить, что контейнер пода `test-pod-inner` имеет доступ только до контейнера пода `test-pod-outer`:

```shell
kubectl exec -it pods/test-pod-inner -- sh
curl -sS -D - -o /dev/null http://10.233.102.131
curl -sS -D - -o /dev/null https://google.com
```

```text
HTTP/1.1 200 OK
<...>

curl: (6) Could not resolve host: google.com
```

PS. Использованные флаги для `curl`:
* `-s` - silent, не выводить никакую информацию о запросе
* `-S` - show-errors, несмотря на флаг `-s` выводит информацию об ошибке, если такая произошла при запросе.
* `-D` - dump-headers, вывести заголовки ответа в файл. Если указать в качестве пути `-`, то вывод будет произведён в stdout.
* `-o` - output, вывести тело запроса в файл. В данном случае в `/dev/null`.
