# Домашняя работа к занятию 12.1 «Компоненты Kubernetes»

Вы DevOps инженер в крупной компании с большим парком сервисов. Ваша задача — разворачивать эти продукты в корпоративном кластере. 

## Задача 1: Установить Minikube

>Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине Minikube.
>
> <details><summary>Инструкция по установке</summary>
>
>### Как поставить на AWS:
>- создать EC2 виртуальную машину (Ubuntu Server 20.04 LTS (HVM), SSD Volume Type) с типом **t3.small**. Для работы потребуется настроить Security Group для доступа по ssh. Не забудьте указать keypair, он потребуется для подключения.
>- подключитесь к серверу по ssh (ssh ubuntu@<ipv4_public_ip> -i <keypair>.pem)
>- установите миникуб и докер следующими командами:
>  - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
>  - chmod +x ./kubectl
>  - sudo mv ./kubectl /usr/local/bin/kubectl
>  - sudo apt-get update && sudo apt-get install docker.io conntrack -y
>  - curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
>- проверить версию можно командой minikube version
>- переключаемся на root и запускаем миникуб: minikube start --vm-driver=none
>- после запуска стоит проверить статус: minikube status
>- запущенные служебные компоненты можно увидеть командой: kubectl get pods --namespace=kube-system
>
>### Для сброса кластера стоит удалить кластер и создать заново:
>- minikube delete
>- minikube start --vm-driver=none
>
>Возможно, для повторного запуска потребуется выполнить команду: sudo sysctl fs.protected_regular=0
>
>Инструкция по установке Minikube - [ссылка](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)
>
>**Важно**: t3.small не входит во free tier, следите за бюджетом аккаунта и удаляйте виртуалку.
>
> </details>

Установил на локальной машине:

```console
dmitry@Lenovo-B50:~# minikube version
minikube version: v1.26.1
commit: 62e108c3dfdec8029a890ad6d8ef96b6461426dc
dmitry@Lenovo-B50:~$ sudo -i
root@Lenovo-B50:~# minikube start --vm-driver=none
* minikube v1.26.1 on Ubuntu 22.04
* Using the none driver based on existing profile
* Starting control plane node minikube in cluster minikube
* Running on localhost (CPUs=4, Memory=6906MB, Disk=223751MB) ...
* OS release is Ubuntu 22.04.1 LTS
* Preparing Kubernetes v1.24.3 on Docker 20.10.12 ...
  - kubelet.resolv-conf=/run/systemd/resolve/resolv.conf
    > kubectl.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubeadm.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubelet.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubectl:  43.59 MiB / 43.59 MiB [--------------] 100.00% 2.36 MiB p/s 19s
    > kubeadm:  42.32 MiB / 42.32 MiB [--------------] 100.00% 1.67 MiB p/s 26s
    > kubelet:  110.64 MiB / 110.64 MiB [------------] 100.00% 3.08 MiB p/s 36s
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring local host environment ...
*
! The 'none' driver is designed for experts who need to integrate with an existing VM
* Most users should use the newer 'docker' driver instead, which does not require root!
* For more information, see: https://minikube.sigs.k8s.io/docs/reference/drivers/none/
*
! kubectl and minikube configuration will be stored in /root
! To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:
*
  - sudo mv /root/.kube /root/.minikube $HOME
  - sudo chown -R $USER $HOME/.kube $HOME/.minikube
*
* This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: default-storageclass, storage-provisioner
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
root@Lenovo-B50:~# kubectl get pods --namespace=kube-system
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-6d4b75cb6d-qkrnx             1/1     Running   0          47s
etcd-lenovo-b50                      1/1     Running   0          58s
kube-apiserver-lenovo-b50            1/1     Running   0          58s
kube-controller-manager-lenovo-b50   1/1     Running   0          58s
kube-proxy-tqxnw                     1/1     Running   0          47s
kube-scheduler-lenovo-b50            1/1     Running   0          58s
storage-provisioner                  1/1     Running   0          55s
```

## Задача 2: Запуск Hello World
>После установки Minikube требуется его проверить. Для этого подойдет стандартное приложение hello world. А для доступа к нему потребуется ingress.
>
>- развернуть через Minikube тестовое приложение по [туториалу](https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-minikube)
>- установить аддоны ingress и dashboard

### Развернуть через Minikube тестовое приложение
Деплоймент

```console
root@Lenovo-B50:~# kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           17m
```
Сервисы

```console
root@Lenovo-B50:~# kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.110.244.29   <pending>     8080:31295/TCP   17m
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          48m
```

Под

```console
root@Lenovo-B50:~# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6d5f754cc9-xb79z   1/1     Running   0          17m
```

Сервисы minikube

```console
root@Lenovo-B50:~# minikube service list
|-------------|------------|--------------|----------------------------|
|  NAMESPACE  |    NAME    | TARGET PORT  |            URL             |
|-------------|------------|--------------|----------------------------|
| default     | hello-node |         8080 | http://192.168.0.193:31295 |
| default     | kubernetes | No node port |
| kube-system | kube-dns   | No node port |
|-------------|------------|--------------|----------------------------|
```

### Установить аддоны ingress и dashboard

```console
rroot@Lenovo-B50:~# minikube addons list | grep enabled
| dashboard                   | minikube | enabled ✅   | kubernetes                     |
| default-storageclass        | minikube | enabled ✅   | kubernetes                     |
| ingress                     | minikube | enabled ✅   | unknown (third-party)          |
| metrics-server              | minikube | enabled ✅   | kubernetes                     |
| storage-provisioner         | minikube | enabled ✅   | google                         |
```

## Задача 3: Установить kubectl

>Подготовить рабочую машину для управления корпоративным кластером. Установить клиентское приложение kubectl.
>- подключиться к minikube 
>- проверить работу приложения из задания 2, запустив port-forward до кластера

- Тест `minikube`:
```console
root@Lenovo-B50:~# kubectl version --short
Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
Client Version: v1.25.0
Kustomize Version: v4.5.7
Server Version: v1.24.3
```
- Тест `port-forward`, лог `kubectl`:
```console
root@Lenovo-B50:~# kubectl port-forward service/hello-node 8080:8080
  Forwarding from 127.0.0.1:8080 -> 8080
  Forwarding from [::1]:8080 -> 8080
  ^[|Handling connection for 8080
```
- Тест `port-forward`, вывод `curl`:
```console
root@Lenovo-B50:~# curl localhost:8080
  CLIENT VALUES:
  client_address=127.0.0.1
  command=GET
  real path=/
  query=nil
  request_version=1.1
  request_uri=http://localhost:8080/

  SERVER VALUES:
  server_version=nginx: 1.10.0 - lua: 10001

  HEADERS RECEIVED:
  accept=*/*
  host=localhost:8080
  user-agent=curl/7.74.0
  BODY:
  -no body in request-0
```


## Задача 4 (*): собрать через ansible (необязательное)

>Профессионалы не делают одну и ту же задачу два раза. Давайте закрепим полученные навыки, автоматизировав выполнение заданий  ansible-скриптами. При выполнении задания обратите внимание на доступные модули для k8s под ansible.
> - собрать роль для установки minikube на aws сервисе (с установкой ingress)
> - собрать роль для запуска в кластере hello world
  
  ---


