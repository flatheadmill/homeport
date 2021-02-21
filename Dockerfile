FROM alpine AS pruned
COPY . /usr/share/homeport/

FROM scratch
WORKDIR /data
COPY --from=pruned /usr/share/homeport/ /usr/share/homeport/
VOLUME /data
CMD [ "fake" ]
