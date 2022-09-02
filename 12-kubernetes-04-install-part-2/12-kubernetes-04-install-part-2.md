# Домашняя работа к занятию 12.4 «Развертывание кластера на собственных серверах, лекция 2»
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
>Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
>- подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
>- в качестве CRI — containerd;
>- запуск etcd производить на мастере.

### 5 нод: 1 мастер и 4 рабочие ноды

- [inventory](./12-kubernetes-04-install-part-2/kubespray/inventory/mycluster/inventory.ini) файл
- Ноды:
    ```console
  root@n124-control-0:~# kubectl get nodes
  NAME             STATUS    ROLES            AGE		VERSION
  n124-control-0   Ready     control-plane    35m         v1.24.2    
  n124-worker-0    Ready     <none>           35m         v1.24.2
  n124-worker-1    Ready     <none>           35m         v1.24.2
  n124-worker-2    Ready     <none>           35m         v1.24.2
  n124-worker-3    Ready     <none>           35m         v1.24.2
  root@n124-control-0:~#
    ```
- Поды:
  ```console
  root@n124-control-0:~# kubectl get pods -A -o wide
  NAMESPACE		NAME					READY		STATUS		RESTARTS	AGE		IP       	NODE		NOMINATED NODE	READINESS GATES
  kube-system		calico-node-msr7k			1/1		Running		0		19m		10.128.0.27	n124-control-0	<none>		<none>
  kube-system		calico-node-56ckw			1/1		Running		0		19m		10.128.0.29	n124-worker-1	<none>		<none>
  kube-system		calico-node-8ska7			1/1		Running		0		19m		10.128.0.16	n124-worker-3	<none>		<none>
  kube-system		calico-node-xh3ql			1/1		Running		0		19m		10.128.0.34	n124-worker-0	<none>		<none>
  kube-system		calico-node-pl8em			1/1		Running		0		19m		10.128.0.9	n124-worker-2	<none>		<none>
  kube-system		coredns-6d4b75cb6d-fber5	        1/1		Running		0		19m		10.233.114.1	n124-control-0	<none>		<none>
  kube-system		coredns-6d4b75cb6d-nw8kj		1/1		Running		0		19m		10.233.89.1	n124-worker-0	<none>		<none>
  kube-system		dns-autoscaler-48v7756x93-shw5b		1/1		Running		0		19m		10.233.114.2	n124-control-0	<none>		<none>
  kube-system		kube-apiserver-n124-control-0		1/1		Running		1		19m		10.128.0.27	n124-control-0	<none>		<none>
  kube-system		kube-controller-manager-n124-control-0	1/1		Running		1		19m		10.128.0.27	n124-control-0	<none>		<none>
  kube-system		kube-proxy-bz3fo			1/1		Running		0		19m		10.128.0.9	n124-worker-2	<none>		<none>
  kube-system		kube-proxy-m8dd2			1/1		Running		0		19m		10.128.0.29	n124-worker-1	<none>		<none>
  kube-system		kube-proxy-d65wh			1/1		Running		0		19m		10.128.0.34	n124-worker-0	<none>		<none>
  kube-system		kube-proxy-r2cej			1/1		Running		0		19m		10.128.0.27	n124-control-0	<none>		<none>
  kube-system		kube-proxy-vu41k			1/1		Running		0		19m		10.128.0.16	n124-worker-3	<none>		<none>
  kube-system		kube-scheduler-n124-control-0		1/1		Running		1		19m		10.128.0.27	n124-control-0	<none>		<none>
  kube-system		nginx-proxy-n124-worker-0		1/1		Running		0		19m		10.128.0.34	n124-worker-0	<none>		<none>
  kube-system		nginx-proxy-n124-worker-1		1/1		Running		0		19m		10.128.0.29	n124-worker-1	<none>		<none>
  kube-system		nginx-proxy-n124-worker-2		1/1		Running		0		19m		10.128.0.9	n124-worker-2	<none>		<none>
  kube-system		nginx-proxy-n124-worker-3		1/1		Running		0		19m		10.128.0.16	n124-worker-3	<none>		<none>
  kube-system		node-localdns-8k9kh			1/1		Running		0		19m		10.128.0.29	n124-worker-1	<none>		<none>
  kube-system		node-localdns-m93oq			1/1		Running		0		19m		10.128.0.34	n124-worker-0	<none>		<none>
  kube-system		node-localdns-4xls5			1/1		Running		0		19m		10.128.0.9	n124-worker-2	<none>		<none>
  kube-system		node-localdns-ab2sf			1/1		Running		0		19m		10.128.0.16	n124-worker-3	<none>		<none>
  kube-system		node-localdns-jz61f			1/1		Running		0		19m		10.128.0.27	n124-control-0	<none>		<none>
  root@n124-control-0:~#
   ```

### В качестве CRI — containerd;

- Листинг контейнеров в `crictl`:
    ```console
  root@n124-control-0:~# crictl ps
  CONTAINER	IMAGE		CREATED		STATE		NAME			ATTEMPT		POD ID		POD
  j63mv837f6skj	5cnw73mfhywop	25 minutes ago	Running		kube-apiserver		1		jhadsca63jg45	kube-apiserver-n124-control-0
  b27997vvf65sl	kjad76d87a1na	25 minutes ago	Running		node-cache		0		2874525jhcvs9	node-localdns-m93oq
  87794872n2937	4vsr915g7g234   25 minutes ago	Running		autoscaler		0		zj7q34mn459ds	dns-autoscaler-48v7756x93-shw5b
  5s88h69s92387	b38skt7vm492m	25 minutes ago	Running		coredns			0		s45dkdf99svkj	coredns-6d4b75cb6d-fber5
  lkjdv87ejra53	nmsv7wshjd72j	25 minutes ago	Running		calico-node		0		3mnvs8sj8345j	calico-node-msr7k
  ladc765an02tc	1mxje63jv93bx	25 minutes ago	Running		kube-proxy		0		bau6294kas72k	kube-proxy-bz3fo
  8sh25jc23malk	ks7j3kb7dja8d	25 minutes ago	Running		kube-controller-manager	1		340vmwoa5dajl	kube-controller-manager-n124-control-0
  tcvbds65249in	2xkf74k7ds7hs	25 minutes ago	Running		kube-scheduler		1		ahga83kjjakca	kube-scheduler-n124-control-0	
  root@n124-control-0:~#
    ```

### Запуск etcd производить на мастере

- etcd на control ноде:
    ```console
  root@n124-control-0:~# {
  >     etcdctl endpoint status \
  >	  --write-out=table \
  >	  --endpoints=https://localhost:2379 \
  >	  --cacert=/etc/ssl/etcd/ssl/ca.pem \
  >	  --cert=/etc/ssl/etcd/ssl/member-n124-control-0.pem \
  >	  --key=/etc/ssl/etcd/ssl/member-n124-control-0-key.pem
  > }
  +-----------------------+--------------------+----------+-----------+-------------+-----------+-----------+------------+--------------------+--------+
  |	ENDPOINT	|	  ID	     |	VERSION	|  DB SIZE  |  IS LEADER  | IS LEANER |	RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |	
  +-----------------------+--------------------+----------+-----------+-------------+-----------+-----------+------------+--------------------+--------+
  |https://localhost:2379	|  rv314sx6034f5v66  |	3.5.3	|   9.7 MB  |       true  |     false |         3 |       9511 |               9511 |        |
  +-----------------------+--------------------+----------+-----------+-------------+-----------+-----------+------------+--------------------+--------+
  root@n124-control-0:~#
    ```

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
>Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
>- разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
>- работать должны на минимально допустимых EC2 — t3.small.

Делал всё в Yandex Cloud

Весь стек, включая ноды и кластер, поднимаются Терраформом:
1. [prepare.tf](./12-kubernetes-04-install-part-2/prepare.tf) выполняет `git clone` Kubespray, ставит зависимости и копирует папку для инвентори из шаблона
1. [yandex.tf](./12-kubernetes-04-install-part-2/yandex.tf) разворачивает ноды
1. [inventory.tf](./12-kubernetes-04-install-part-2/inventory.tf) подготавливает [inventory.ini](./12-kubernetes-04-install-part-2/kubespray/inventory/mycluster/inventory.ini) из шаблона [inventory.tpl](./12-kubernetes-04-install-part-2/templates/inventory.tpl) с помощью модулей `template_file` и `null_resource`
1. [ansible.tf](./12-kubernetes-04-install-part-2/ansible.tf) разворачивает кластер с помощь Kubespray

