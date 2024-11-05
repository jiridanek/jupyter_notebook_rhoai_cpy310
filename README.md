```shell
brew install pipenv python@3.10
pipenv lock --extra-pip-args "--only-binary=:all: --platform=manylinux_2_28_x86_64 --python-version=3.10 --implementation=cp"
podman build --platform linux/amd64 -t python3.10 .

# this simulates how openshift/notebook-controller runs the image, use it for quick testing
podman run --platform linux/amd64 --user 4432448:0 --workdir=/opt/app-root/src --volume=/opt/app-root/src -p 8888:8888 --rm -it localhost/python3.10:latest

podman tag localhost/python3.10:latest quay.io/jdanek/scratch:python3.10
podman push quay.io/jdanek/scratch:python3.10
```
