FROM golang:alpine AS go-builder

ENV DOCKER_GEN_VERSION=0.7.4

# Install build dependencies for docker-gen
RUN apk add --update \
        curl \
        wget \
        grep
        
RUN curl -s https://api.github.com/repos/ledgetech/lua-resty-http/releases/latest | grep tarball_url | cut -d '"' -f 4 | wget -qi- --output-document=lua-resty-http.gz.tar
RUN curl -s https://api.github.com/repos/bungle/lua-resty-session/releases/latest | grep tarball_url | cut -d '"' -f 4 | wget -qi- --output-document=lua-resty-session.gz.tar
RUN curl -s https://api.github.com/repos/cdbattags/lua-resty-jwt/tags | grep tarball_url | head -1 | cut -d '"' -f 4 | wget -qi- --output-document=lua-resty-jwt.gz.tar

