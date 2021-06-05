FROM debian:latest
WORKDIR /work
COPY generate.sh /
ENV IGNORE=''
CMD /generate.sh
ENTRYPOINT ["/generate.sh"]
