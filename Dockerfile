ARG image=alpine
FROM ${image} as debug
ENV RC_PREFIX=/rc
COPY ./rc/profile /etc
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

FROM ${image} as rc
ENV RC_PREFIX=/etc
COPY ./rc/profile /etc
COPY ./rc ${RC_PREFIX}/rc
RUN . /etc/profile
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
