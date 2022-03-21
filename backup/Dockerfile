# syntax=docker/dockerfile:labs

ARG image=alpine

#FROM scratch as cp
#COPY ./rc /etc/rc
#
#ONBUILD

FROM scratch as git

FROM ${image} as debug
ENV RC_PREFIX=/rc
COPY ./rc/profile /etc
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

FROM ${image} as production
ADD https://github.com/j5pu/rc/tarball/main /tmp

ENV RC_PREFIX=/etc
COPY ./rc/profile /etc
COPY ./rc ${RC_PREFIX}/rc
RUN . /etc/profile
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
