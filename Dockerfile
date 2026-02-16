FROM alpine:3.20

RUN apk add --no-cache curl netcat-openbsd

WORKDIR /app
COPY check.sh /app/check.sh
COPY targets.txt /app/targets.txt
RUN chmod +x /app/check.sh

CMD ["/app/check.sh"]