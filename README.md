# docker-micropython
builds a ~7MB docker image with micropython, based on alpine.

## building
### latest from pfalcon/micropython a.k.a pycopy
    docker build -t micropython:latest .
### current official release
    docker build -t micropython:v1.10 --build-arg MPY_REPO=micropython/micropython --build-arg MPY_COMMIT=v1.10 .

## running
    docker run --rm -it micropython
    docker run --rm -t --entrypoint /bin/sh micropython -c "/bin/micropython /app/myapp.py"

## exiting
    >>> import sys
    >>> sys.exit()
