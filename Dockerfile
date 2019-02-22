FROM alpine AS build

RUN apk --update add --no-cache python3 build-base mbedtls-dev libffi-dev bsd-compat-headers git

ARG MPY_REPO=pfalcon/micropython
ARG MPY_COMMIT=pfalcon

RUN \
  git clone --branch $MPY_COMMIT --single-branch --depth 1 https://github.com/$MPY_REPO.git /tmp/micropython && \
  git -C /tmp/micropython submodule update --init /tmp/micropython/lib/berkeley-db-1.xx

RUN \
  sed -i -e 's/PYTHON = python/PYTHON = python3/g' /tmp/micropython/py/mkenv.mk && \
  sed -i -e 's/MICROPY_SSL_AXTLS = 1/MICROPY_SSL_AXTLS = 0/g' /tmp/micropython/ports/unix/mpconfigport.mk && \
  sed -i -e 's/MICROPY_SSL_MBEDTLS = 0/MICROPY_SSL_MBEDTLS = 1/g' /tmp/micropython/ports/unix/mpconfigport.mk && \
  make -C /tmp/micropython/mpy-cross && \
  make -C /tmp/micropython/ports/unix CFLAGS_EXTRA="-Wno-error=cpp"

#-------------------------------------------------------------------------------

FROM alpine

COPY --from=build /tmp/micropython/ports/unix/micropython /bin/micropython

RUN \
  apk --update add --no-cache libffi mbedtls

ENTRYPOINT /bin/micropython
