ARG image=alpine

FROM alpine as alpine
ENV ENV="/etc/profile"
ENTRYPOINT [ "sh" ]

FROM bash as bash
ENV ENV="/etc/profile"
ENTRYPOINT [ "bash", "-l"]

FROM ${image} AS ps1
ADD profile /etc
