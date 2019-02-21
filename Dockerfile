FROM alpine AS build

RUN \
  apk add python3 build-base libffi-dev mbedtls-dev && \
  echo "@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  apk update

#ARG MPY_REPO=micropython
ARG MPY_REPO=pfalcon
#ARG MPY_VERSION=v1.10
ARG MPY_VERSION=master

ADD https://github.com/$MPY_REPO/micropython/archive/$MPY_VERSION.tar.gz /tmp/micropython.tar.gz
#ADD https://github.com/$MPY_REPO/micropython-lib/archive/$MPY_VERSION.tar.gz /tmp/micropython-lib.tar.gz

COPY ./patches /tmp/patches

RUN \
  mkdir /tmp/micropython /tmp/micropython-lib && \
  tar xf /tmp/micropython.tar.gz --strip 1 -C /tmp/micropython/ && \
  patch /tmp/micropython/ports/unix/mpconfigport.mk /tmp/patches/no-btree.patch && \
  patch /tmp/micropython/ports/unix/mpconfigport.mk /tmp/patches/mbedtls.patch && \
#  tar xf /tmp/micropython-lib.tar.gz --strip 1 -C /tmp/micropython-lib/ && \
#  for l in \
#    array cmath gc math sys ubinascii ucollections uerrno uhashlib uheapq uio ujson \
#    uos ure uselect usocket ussl ustruct utime uzlib _libc \
#    framebuf machine micropython network ucryptolib uctypes ; do \
#    ln -s /tmp/micropython-lib/$l /tmp/micropython/ports/unix/modules/ ; \
#  done && \
  make -C /tmp/micropython/ports/unix

#-------------------------------------------------------------------------------

FROM alpine

RUN \
  apk --update add --no-cache mbedtls libffi

COPY --from=build /tmp/micropython/ports/unix/micropython /bin/micropython

RUN \
  for l in \             
    array cmath gc math sys binascii collections errno hashlib heapq io json os re \
    select socket ssl struct time zlib framebuf machine uctypes ; do \
      /bin/micropython -m upip install micropython-$l ; done

ENTRYPOINT /bin/micropython
