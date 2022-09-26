# Домашняя работа к занятию 13.1 «Контейнеры, поды, deployment, statefulset, services, endpoints»
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
> Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
> - под содержит в себе 2 контейнера — фронтенд, бекенд;
> - регулируется с помощью deployment фронтенд и бекенд;
> - база данных — через statefulset.

Приложения запущены в отдельном неймспейсе `stage`. Манифесты:
- [deployment | Приложение](./13-kubernetes-config-01-objects/stage/app.yml)
- [statefullset | БД](./13-kubernetes-config-01-objects/stage/db.yml)

Вывода команды `kubectl` со списком запущенных объектов каждого типа:

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

## Задание 3 (*): добавить endpoint на внешний ресурс api
> Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
> - добавлен endpoint до внешнего api (например, геокодер).

---


