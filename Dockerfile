ARG GOLANG_VERSION=1.24
ARG ALPINE_VERSION=3.21

FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS builder

ARG wg_go_tag=0.0.20230223-mullvad-0.1.6

ARG wg_tools_tag=v1.0.20210914

RUN apk add --update git build-base libmnl-dev iptables

RUN git clone https://github.com/mullvad/wireguard-go && \
    cd wireguard-go && \
    git checkout $wg_go_tag && \
    make && \
    make install

ENV WITH_WGQUICK=yes
RUN git clone https://git.zx2c4.com/wireguard-tools && \
    cd wireguard-tools && \
    git checkout $wg_tools_tag && \
    cd src && \
    make && \
    make install

COPY healthcheck.go /go/src/healthcheck.go
RUN go build -ldflags="-s -w" -o /go/bin/healthcheck /go/src/healthcheck.go

FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache --update bash libmnl iptables openresolv iproute2

COPY --from=builder /usr/bin/wireguard-go /usr/bin/wg* /usr/bin/
COPY --from=builder /go/bin/healthcheck /usr/bin/healthcheck
COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
