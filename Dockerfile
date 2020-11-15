FROM golang:alpine AS go-builder

ENV DOCKER_GEN_VERSION=0.7.4

# Install build dependencies for docker-gen
RUN apk update \
  && apk upgrade \
  && apk add curl wget grep \
  && cd /tmp \
  && curl -s https://api.github.com/repos/ledgetech/lua-resty-http/releases/latest | grep tarball_url | cut -d '"' -f 4 | wget -qi- --output-document=lua-resty-http.gz.tar \
  && curl -s https://api.github.com/repos/bungle/lua-resty-session/releases/latest | grep tarball_url | cut -d '"' -f 4 | wget -qi- --output-document=lua-resty-session.gz.tar \
  && curl -s https://api.github.com/repos/cdbattags/lua-resty-jwt/tags | grep tarball_url | head -1 | cut -d '"' -f 4 | wget -qi- --output-document=lua-resty-jwt.gz.tar \
  && curl -s https://api.github.com/repos/zmartzone/lua-resty-openidc/releases/latest | grep tarball_url | cut -d '"' -f 4 | wget -qi- --output-document=lua-resty-openidc.gz.tar

RUN tar -zxf /tmp/lua-resty-http.gz.tar \
  && tar -zxf /tmp/lua-resty-session.gz.tar \
  && tar -zxf /tmp/lua-resty-jwt.gz.tar \
  && tar -zxf /tmp/lua-resty-openidc.gz.tar \
  && mkdir /tmp/openresty \
  && cp -r ledgetech-lua-resty-http*/lib/resty/* /tmp/openresty/ \
  && cp -r bungle-lua-resty-session*/lib/resty/* /tmp/openresty/ \
  && cp -r cdbattags-lua-resty-jwt*/lib/resty/* /tmp/openresty/ \
  && cp -r zmartzone-lua-resty-openidc*/lib/resty/* /tmp/openresty/

FROM openresty/openresty:alpine

LABEL maintainer="Remo Gloor"

COPY --from=go-builder /tmp/openresty/ /usr/local/openresty/lualib/resty/
COPY bootstrap.sh /usr/local/openresty/bootstrap.sh
RUN chmod 755 /usr/local/openresty/bootstrap.sh
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/local/openresty/bootstrap.sh"]
