# Домашняя работа к занятию 13.1 «Контейнеры, поды, deployment, statefulset, services, endpoints»
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
> Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
> - под содержит в себе 2 контейнера — фронтенд, бекенд;
> - регулируется с помощью deployment фронтенд и бекенд;
> - база данных — через statefulset.

Приложения запущены в отдельном неймспейсе `stage`. Манифесты:
- [deployment | Приложение](./stage/app.yml)
- [statefullset | БД](./stage/db.yml)

Выводы команды `kubectl` со списком запущенных объектов каждого типа:

```console
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/stage$ kubectl get po
NAME                      READY   STATUS    RESTARTS         AGE
fb-pod-7644b6776f-l7pxq   2/2     Running   0                23m
postgres-db-0             1/1     Running   0                23m
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/stage$ kubectl get deploy
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
fb-pod   1/1     1            1           23m
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/stage$ kubectl get svc
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
fb-svc           NodePort       10.97.238.14    <none>        80:30080/TCP     23m
kubernetes       ClusterIP      10.96.0.1       <none>        443/TCP          35m
postgres-db-lb   LoadBalancer   10.97.154.249   <pending>     5432:31118/TCP   23m
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/stage$ kubectl get statefulset
NAME          READY   AGE
postgres-db   1/1     23m
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/stage$
```



## Задание 2: подготовить конфиг для production окружения
> Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
> - каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
> - для связи используются service (у каждого компонента свой);
> - в окружении фронта прописан адрес сервиса бекенда;
> - в окружении бекенда прописан адрес сервиса базы данных.

Приложения запущены в отдельном неймспейсе `prod`. Манифесты:
* [deployment | backend](./prod/back.yml)
* [deployment | fronend](./prod/front.yml)
* [statefullset | БД](./prod/db.yml)

Выводы команды `kubectl` со списком запущенных объектов каждого типа:

```console
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$ kubectl apply -f front.yml -f back.yml -f db.yml
deployment.apps/prod-f created
service/produ-f created
deployment.apps/prod-b created
service/prod-b created
statefulset.apps/postgres created
configmap/postgres-config created
service/postgres created
persistentvolume/nfs-pv-prod created
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$ kubectl get po
NAME                      READY   STATUS    RESTARTS   AGE
postgres-0                1/1     Running   0          55m26s
prod-b-5b9858c56c-8p8mf   1/1     Running   0          55m26s
prod-b-5b9858c56c-r6pw2   1/1     Running   0          55m26s
prod-f-cb676886b-g8zkv    1/1     Running   0          55m26s
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$ kubectl get deploy
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
prod-b   2/2     2            2           56m8s
prod-f   1/1     1            1           56m8s
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                          STORAGECLASS   REASON   AGE
nfs-pv-prod                                1Gi        RWX            Retain           Available                                                          56m30s
pvc-83695188-5158-4767-98a1-25fdb3956ab5   1Gi        RWX            Delete           Bound       default/postgredb-postgres-0   standard                56m30s
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$ kubectl get pvc
NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
postgredb-postgres-0   Bound    pvc-83695188-5158-4767-98a1-25fdb3956ab5   1Gi        RWX            standard       57m28s
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP          2h11m
postgres     NodePort    10.108.152.3    <none>        5432:31488/TCP   58m18s
prod-b       NodePort    10.98.191.25    <none>        8080:32712/TCP   58m18s
produ-f      NodePort    10.104.64.246   <none>        8080:31960/TCP   58m18s
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$ kubectl get statefulset
NAME       READY   AGE
postgres   1/1     58m49s
dmitry@Lenovo-B50:~/netology/devkub/13-kubernetes-config-01-objects/prod$
```

## Задание 3 (*): добавить endpoint на внешний ресурс api
> Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
> - добавлен endpoint до внешнего api (например, геокодер).

---


