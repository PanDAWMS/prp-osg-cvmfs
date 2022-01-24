# Create the frontier namespace
kubectl create -f namespace-frontier.yaml
# Create the frontier configuration config map
kubectl create -f config-map-frontier.yaml
# Create a frontier pod in the cvmfs namespace
kubectl create -f frontier.yaml
# Also create a service to make it easy to discover
kubectl create -f service-frontier.yaml

