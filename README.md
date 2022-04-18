# docker-micropython
builds a ~7MB docker alpine image with pfalcon/pycopy micropython

## building
### latest from pfalcon/micropython a.k.a pycopy
    docker build -t micropython:latest .

### build specific release
    docker build -t micropython:v3.6.1 --build-arg MPY_REPO=pfalcon/pycopy --build-arg MPY_COMMIT=v3.6.1 .

## running
    docker run --rm -it micropython
    docker run --rm -t --entrypoint /bin/sh micropython -c "/bin/micropython /app/myapp.py"

## exiting
    >>> import sys
    >>> sys.exit()
or press ctrl+D in the interpreter
