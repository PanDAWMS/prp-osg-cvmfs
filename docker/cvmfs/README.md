Command to build multi architecture image
```
docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag fbarreir/cvmfs-multiarch:latest .
```