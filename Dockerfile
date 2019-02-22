FROM alpine AS build

RUN apk --update add --no-cache python3 build-base libffi-dev mbedtls-dev

ARG MPY_REPO=pfalcon/micropython
ARG MPY_VERSION=pfalcon

ADD https://github.com/$MPY_REPO/archive/$MPY_VERSION.tar.gz /tmp/micropython.tar.gz

COPY ./patches /tmp/patches

RUN \
  mkdir /tmp/micropython /tmp/micropython-lib && \
  tar xf /tmp/micropython.tar.gz --strip 1 -C /tmp/micropython/ && \
  patch /tmp/micropython/ports/unix/mpconfigport.mk /tmp/patches/no-btree.patch && \
  patch /tmp/micropython/ports/unix/mpconfigport.mk /tmp/patches/mbedtls.patch && \
  make -C /tmp/micropython/ports/unix

#-------------------------------------------------------------------------------

FROM alpine

COPY --from=build /tmp/micropython/ports/unix/micropython /bin/micropython

RUN \
  apk --update add --no-cache mbedtls libffi
  for l in \             
    array cmath gc math sys binascii collections errno hashlib heapq io json os re \
    select socket ssl struct time zlib framebuf machine uctypes ; do \
      /bin/micropython -m upip install micropython-$l ; done

ENTRYPOINT /bin/micropython
