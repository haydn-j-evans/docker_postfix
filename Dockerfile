FROM alpine:3.12

# Install supervisor, postfix
# Install postfix first to get the first account (101)
# Install opendkim second to get the second account (102)
RUN        true && \
           apk add --no-cache --upgrade cyrus-sasl cyrus-sasl-plain cyrus-sasl-login && \
           apk add --no-cache libsasl && \
           apk add --no-cache cyrus-sasl-dev && \
           apk add --no-cache postfix && \
           apk add --no-cache opendkim && \
           apk add --no-cache openssl && \
           apk add --no-cache curl && \
           apk add --no-cache --upgrade ca-certificates tzdata supervisor rsyslog musl musl-utils bash opendkim-utils && \
           apk add --no-cache --upgrade libcurl jsoncpp && \
           (rm "/tmp/"* 2>/dev/null || true) && (rm -rf /var/cache/apk/* 2>/dev/null || true)
           
# Set up configuration
COPY       /configs/supervisord.conf     /etc/supervisord.conf
COPY       /configs/rsyslog*.conf        /etc/
COPY       /configs/opendkim.conf        /etc/opendkim/opendkim.conf
COPY       /configs/smtp_header_checks   /etc/postfix/smtp_header_checks
COPY       /scripts/*.sh                 /

# Copy and update Centogene Root Certificates

RUN curl http://crl.centogene.com/aia/Root-Centogene-CA-PEM.crt >> /usr/local/share/ca-certificates/Root-Centogene-CA.crt
RUN curl http://crl.centogene.com/aia/Issu1-Centogene-CA-PEM.crt >> /usr/local/share/ca-certificates/Issu1-Centogene-CA.crt
RUN curl http://crl.centogene.com/aia/Issu2-Centogene-CA-PEM.crt >> /usr/local/share/ca-certificates/Issu2-Centogene-CA.crt

RUN update-ca-certificates

# Define scripts as executable

RUN        chmod +x /run.sh /opendkim.sh

# Set up volumes
VOLUME     [ "/var/spool/postfix", "/etc/postfix", "/etc/opendkim/keys", "/etc/postfix/certs" ]

# Run supervisord
USER       root
WORKDIR    /tmp

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD printf "EHLO healthcheck\n" | nc localhost 587 | grep -qE "^220.*ESMTP Postfix"

EXPOSE     587
CMD        [ "/bin/sh", "-c", "/run.sh" ]
