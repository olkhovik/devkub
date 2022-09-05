```
kubectl exec hello-node-7f6g865vv1-nl5y8 -- curl -m 1 -s http://10.231.47.3:8080 | grep -e request_uri -e host -e client_address
kubectl exec hello-node-7f6g865vv1-zbfcm -- curl -m 1 -s http://10.231.47.2:8080 | grep -e request_uri -e host -e client_address
```
```
$ kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE            NOMINATED NODE   READINESS GATES
hello-node-7f6g865vv1-nl5y8   1/1     Running   0          91m   10.231.47.2   n125-worker-0   <none>           <none>
hello-node-7f6g865vv1-zbfcm   1/1     Running   0          91m   10.231.47.3   n125-worker-0   <none>           <none>
```

