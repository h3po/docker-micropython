# docker-micropython
dockerfile for the micropython unix port

builds a ~7MB docker image with micropython, based on alpine.

## building
docker build -t micropython .

## running
docker run --rm -it micropython

## exiting
    >>> import sys
    >>> sys.exit()
