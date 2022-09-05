```
kubectl exec hello-node-6b89d599b9-2vtqk -- curl -s http://10.216.37.105:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-2vtqk -- curl -s http://10.216.37.124:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-2vtqk -- curl -s http://localhost:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-lf9qt -- curl -s http://10.216.37.105:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-lf9qt -- curl -s http://localhost:8080 --connect-timeout 3
```
```
12:16:03 ~ dmitry@Lenovo-B50:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni (main=)$ kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE     IP              NODE              NOMINATED NODE   READINESS GATES
hello-node-6b89d599b9-2vtqk   1/1     Running   0          127m    10.244.88.105   netology122-vm1   <none>           <none>
hello-node-6b89d599b9-lf9qt   1/1     Running   0          3h55m   10.244.88.124   netology122-vm1   <none>           <none>
```
