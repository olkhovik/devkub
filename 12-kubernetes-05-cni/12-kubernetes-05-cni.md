# Домашняя работа к занятию 12.5 «Сетевые решения CNI»
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
>Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
>- установка производится через ansible/kubespray;
>- после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

###  Установка производится через ansible/kubespray

Установил связкой [terraform + kubespray + ansible](./terraform/):

Ноды:
```console
$ yclist
VM
+----------------------+----------------+---------------+---------+---------------+-------------+
|          ID          |      NAME      |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+----------------+---------------+---------+---------------+-------------+
| gjzsjsgi97dz7i15inh4 | n125-worker-0  | ru-central1-a | RUNNING | 51.250.65.138 | 10.121.0.7  |
| gjztjstrzikt9gjw4zq9 | n125-control-0 | ru-central1-a | RUNNING | 51.250.65.17  | 10.121.0.15 |
+----------------------+----------------+---------------+---------+---------------+-------------+
```

```console
$ kubectl get nodes -o wide
NAME             STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
n125-control-0   Ready    control-plane   83m   v1.24.2   10.121.0.15   <none>        Ubuntu 20.04.4 LTS   5.4.0-120-generic   containerd://1.6.6
n125-worker-0    Ready    <none>          81m   v1.24.2   10.121.0.7    <none>        Ubuntu 20.04.4 LTS   5.4.0-120-generic   containerd://1.6.6
```

деплоймент:
```console
$ kubectl get deploy -o wide
NAME         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
hello-node   2/2     2            2           80m   echoserver   k8s.gcr.io/echoserver:1.4   app=hello-node
```

поды:
```console
$ kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE            NOMINATED NODE   READINESS GATES
hello-node-7f6g865vv1-nl5y8   1/1     Running   0          81m   10.231.47.2   n125-worker-0   <none>           <none>
hello-node-7f6g865vv1-zbfcm   1/1     Running   0          81m   10.231.47.3   n125-worker-0   <none>           <none>
```

сервисы:
```console
$ kubectl get services -o wide
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE   SELECTOR
hello-node   LoadBalancer   10.231.25.38   <pending>     8080:31619/TCP   81m   app=hello-node
kubernetes   ClusterIP      10.231.0.1     <none>        443/TCP          87m   <none>
```

### Настроить политику доступа к hello-world извне

Добавил две политики:
- [accept-pods-communication](./policies/accept-pods-communication.yml) - разрешает хождение трафика между репликами hello-node
- [default-ingress-deny](./policies/default-ingress-deny.yml) - запрещает прочие коммуникации

Проверяем доступ без политик
```console
$ kubectl get netpol -A
No resources found
```
- Доступ от одного пода к другому - работает
    ```console
    14:16:23 ~ dmitry@Lenovo-B50:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ kubectl exec hello-node-7f6g865vv1-nl5y8 -- curl -m 1 -s http://10.231.47.3:8080 | grep -e request_uri -e host -e client_address
    client_address=10.231.47.2
    request_uri=http://10.231.47.3:8080/
    host=10.231.47.3:8080
    14:17:05 ~ dmitry@Lenovo-B50:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ kubectl exec hello-node-7f6g865vv1-zbfcm -- curl -m 1 -s http://10.233.72.2:8080 | grep -e request_uri -e host -e client_address
    client_address=10.231.47.3
    request_uri=http://10.231.47.2:8080/
    host=10.231.47.2:8080
    ```
- Доступ извне - работает
    ```console
    14:18:45 ~ dmitry@Lenovo-B50:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ curl -s -m 1 http://51.250.65.17:31619 | grep -e request_uri -e host -e client_address
    client_address=10.231.101.0
    request_uri=http://51.250.65.17:8080/
    host=51.250.65.17:31619
    ```
применяем политики
```console
$ kubectl apply -f accept-pods-communication.yml
networkpolicy.networking.k8s.io/accept-pods-communication created
```
```console
$ kubectl apply -f default-ingress-deny.yml
networkpolicy.networking.k8s.io/default-deny-ingress created
```
```console
$ kubectl get netpol -A
NAMESPACE   NAME                        POD-SELECTOR     AGE
default     accept-pods-communication   app=hello-node   27s
default     default-deny-ingress        app=hello-node   19s
```

- доступ от одного пода к другому - по-прежнему работает
    ```console
    14:20:34 ~ dmitry@Lenovo-B50:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ kubectl exec hello-node-7f6g865vv1-nl5y8 -- curl -m 1 -s http://10.231.47.3:8080 | grep -e request_uri -e host -e client_address
    client_address=10.231.47.2
    request_uri=http://10.231.47.3:8080/
    host=10.231.47.3:8080
    14:21:03 ~ dmitry@Lenovo-B50:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $  kubectl exec hello-node-7f6g865vv1-zbfcm -- curl -m 1 -s http://10.231.47.2:8080 | grep -e request_uri -e host -e client_address
    client_address=10.231.47.3
    request_uri=http://10.231.47.2:8080/
    host=10.231.47.2:8080
    ```
- доступ извне - не работает
    ```console
    14:22:17 ~ dmitry@Lenovo-B50:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ curl -s -v -m 1 http://51.250.65.17:31619 | grep -e request_uri -e host -e client_address
    *   Trying 51.250.65.17:31619...
    * Connection timed out after 1001 milliseconds
    * Closing connection 0
    ```

## Задание 2: изучить, что запущено по умолчанию
>Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
>Требования: 
>- установить утилиту calicoctl;
>- получить 3 вышеописанных типа в консоли.



