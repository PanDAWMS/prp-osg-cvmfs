This CVMFS plugin requires you to install helm on the client machine
```
# KUBECONFIG needs to point to the right cluster
export KUBECONFIG=/path/to/kubeconfig/file

# To install
helm install cvmfs-helm .

# To uninstall
helm delete cvmfs-helm
```


