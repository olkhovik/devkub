# Домашняя работа к занятию 12.2 «Команды для работы с Kubernetes»
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
>Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 
>
>Требования:
> * пример из hello world запущен в качестве deployment
> * количество реплик в deployment установлено в 2
> * наличие deployment можно проверить командой kubectl get deployment
> * наличие подов можно проверить командой kubectl get pods

- hello world запущен в качестве deployment, количество реплик в deployment установлено в 2:
    ```console
    root@Lenovo-B50:~#  kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 -r 2
    deployment.apps/hello-node created
    ```
- `kubectl get deployment`:
    ```console
    root@Lenovo-B50:~# kubectl get deployment
    NAME         READY   UP-TO-DATE   AVAILABLE   AGE
    hello-node   2/2     2            2           11s
    ```
- `kubectl get pods`:
    ```console
    root@Lenovo-B50:~# kubectl get pods
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-6d5f754cc9-jpwbw   1/1     Running   0          26s
    hello-node-6d5f754cc9-t7tqp   1/1     Running   0          26s
    ```

## Задание 2: Просмотр логов для разработки
>Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
>Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.
>
>Требования: 
> * создан новый токен доступа для пользователя
> * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
> * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

- Создание неймспейса с деплоем hello-node:
    ```console
    root@Lenovo-B50:~# kubectl create namespace app-namespace
    namespace/app-namespace created
    root@Lenovo-B50:~# kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --namespace=app-namespace
    deployment.apps/hello-node created
    ```
- Создание пользователя для разработчика:
    ```console
    root@Lenovo-B50:~# mkdir dev
    root@Lenovo-B50:~# cd dev
    root@Lenovo-B50:~/dev# openssl genrsa -out dev.key 2048
    Generating RSA private key, 2048 bit long modulus (2 primes)
    ..............................................................................................+++++
    .......................................................................+++++
    e is 65537 (0x010001)
    root@Lenovo-B50:~/dev# openssl req -new -key dev.key -out dev.csr -subj "/CN=dev"
    root@Lenovo-B50:~/dev# openssl x509 -req -in dev.csr -CA /root/.minikube/ca.crt -CAkey /root/.minikube/ca.key -CAcreateserial -out dev.crt -days 500
    Signature ok
    subject=CN = dev
    Getting CA Private Key
    root@Lenovo-B50:~/dev# kubectl config set-credentials dev --client-certificate=/root/dev/dev.crt --client-key=/root/dev/dev.key
    User "dev" set.
    root@Lenovo-B50:~/dev# kubectl config set-context app-namespace-dev --namespace=app-namespace --cluster=minikube --user=dev
    Context "app-namespace-dev" created.
    ```
- Проверка, что получилось: сертификат, ключ и подписанный сертификат:
    ```console
    root@Lenovo-B50:~/dev# ll
    total 20
    drwxr-xr-x 2 root root 4096 Aug 25 17:29 ./
    drwx------ 8 root root 4096 Aug 25 17:29 ../
    -rw-r--r-- 1 root root  985 Aug 25 17:29 dev.crt
    -rw-r--r-- 1 root root  883 Aug 25 17:29 dev.csr
    -rw------- 1 root root 1679 Aug 25 17:29 dev.key
    ```
- Cоздание роли:
    ```console
    root@Lenovo-B50:~/dev# cat <<EOF > role.yml
    > apiVersion: rbac.authorization.k8s.io/v1
    > kind: Role
    > metadata:
    >   namespace: app-namespace
    >   name: dev-role
    > rules:
    > - apiGroups: [""]
    >   resources: ["pods", "pods/log"]
    >   verbs: ["get", "list"]
    > EOF
    root@Lenovo-B50:~/dev# kubectl apply -f role.yml
    role.rbac.authorization.k8s.io/dev-role created
    ```
- Создание рольбиндинга:
    ```console
    root@Lenovo-B50:~/dev# cat <<EOF > rolebinding.yml
    > apiVersion: rbac.authorization.k8s.io/v1
    > kind: RoleBinding
    > metadata:
    >   name: dev-rolebinding
    >   namespace: app-namespace
    > subjects:
    > - kind: User
    >   name: dev
    >   apiGroup: rbac.authorization.k8s.io
    > roleRef:
    >   kind: Role
    >   name: dev-role
    >   apiGroup: rbac.authorization.k8s.io
    > EOF
    root@Lenovo-B50:~/dev# kubectl apply -f rolebinding.yml
    rolebinding.rbac.authorization.k8s.io/dev-rolebinding created
    ```
- Переключение контекста:
    ```console
    root@Lenovo-B50:~/dev# kubectl config use-context app-namespace-dev
    Switched to context "app-namespace-dev".
    ```
- Проверка, что пользователь может посмотреть информацию по подам и логи. Логов не оказалось, но и ошибки не возникло:
    ```console
    root@Lenovo-B50:~/dev# kubectl get pods
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-6d5f754cc9-pwrgx   1/1     Running   0          7m15s
    root@Lenovo-B50:~/dev# kubectl describe pods | head -n 3
    Name:         hello-node-6d5f754cc9-pwrgx
    Namespace:    app-namespace
    Priority:     0
    root@Lenovo-B50:~/dev# kubectl logs pods/hello-node-6b89d599b9-whrkr
    root@Lenovo-B50:~/dev#
    ```
- Проверка, что пользователь не может удалить или сделать что-то ещё, например создать деплоймент или посмотреть информацию о нодах:
    ```console
    root@Lenovo-B50:~/dev# kubectl delete pod hello-node-6d5f754cc9-pwrgx
    Error from server (Forbidden): pods "hello-node-6d5f754cc9-pwrgx" is forbidden: User "dev" cannot delete resource "pods" in API group "" in the namespace "app-namespace"
    root@Lenovo-B50:~/dev# kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
    error: failed to create deployment: deployments.apps is forbidden: User "dev" cannot create resource "deployments" in API group "apps" in the namespace "app-namespace"
    root@Lenovo-B50:~/dev# kubectl get nodes
    Error from server (Forbidden): nodes is forbidden: User "dev" cannot list resource "nodes" in API group "" at the cluster scope
    ```

## Задание 3: Изменение количества реплик 
>Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 
>
>Требования:
> * в deployment из задания 1 изменено количество реплик на 5
> * проверить что все поды перешли в статус running (kubectl get pods)

- в `deployment` из задания 1 изменено количество реплик на 5:
    ```console
    root@Lenovo-B50:~# kubectl scale deployment hello-node --replicas=5
    deployment.apps/hello-node scaled
    ```
- проверить что все поды перешли в статус running (`kubectl get pods`):
    ```console
    root@Lenovo-B50:~# kubectl get pods
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-6d5f754cc9-9rn9m   1/1     Running   0          35s
    hello-node-6d5f754cc9-c5tpn   1/1     Running   0          7m21s
    hello-node-6d5f754cc9-gq5hf   1/1     Running   0          35s
    hello-node-6d5f754cc9-kf9lw   1/1     Running   0          35s
    hello-node-6d5f754cc9-szkk8   1/1     Running   0          35s
    ```

---


