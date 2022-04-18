FROM alpine AS build

RUN apk --update add --no-cache python3 build-base libffi-dev bsd-compat-headers git

ARG MPY_REPO=pfalcon/micropython
ARG MPY_COMMIT=v3.6.1

RUN \
  git clone --branch $MPY_COMMIT --single-branch --depth 1 https://github.com/$MPY_REPO.git /tmp/micropython && \
  git -C /tmp/micropython submodule update --init /tmp/micropython/lib/berkeley-db-1.xx && \
  git -C /tmp/micropython submodule update --init /tmp/micropython/lib/mbedtls

RUN \
  sed -i -e 's/MICROPY_SSL_AXTLS = 1/MICROPY_SSL_AXTLS = 0/g' /tmp/micropython/ports/unix/mpconfigport.mk && \
  sed -i -e 's/MICROPY_SSL_MBEDTLS = 0/MICROPY_SSL_MBEDTLS = 1/g' /tmp/micropython/ports/unix/mpconfigport.mk && \
  make -C /tmp/micropython/mpy-cross && \
  make -C /tmp/micropython/ports/unix CFLAGS_EXTRA="-Wno-error=cpp"

#-------------------------------------------------------------------------------

FROM alpine

COPY --from=build /tmp/micropython/ports/unix/pycopy /bin/pycopy

RUN \
  apk --update add --no-cache libffi && \
  ln -s /bin/pycopy /bin/micropython

ENTRYPOINT /bin/micropython
