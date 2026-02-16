FROM alpine:3.20

RUN apk add --no-cache curl netcat-openbsd dos2unix

WORKDIR /app
COPY check.sh /app/check.sh
COPY targets.txt /app/targets.txt

RUN dos2unix /app/check.sh && chmod 755 /app/check.sh

CMD ["/app/check.sh"]