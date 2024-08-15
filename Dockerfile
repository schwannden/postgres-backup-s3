FROM alpine:3.20

# Install necessary packages and clean up afterwards
RUN sed -i 's/https/http/' /etc/apk/repositories && \
    apk add --no-cache ca-certificates && \
    update-ca-certificates && \
    apk add --no-cache postgresql-client curl && \
    rm -rf /var/cache/apk/*

# Install Minio client and clean up the download
RUN curl -kO https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x mc && \
    mv mc /usr/local/bin/ && \
    rm -f mc

# Copy the backup script
COPY databaseBackup/backup.sh /usr/local/bin/backup.sh

# Make the script executable
RUN chmod +x /usr/local/bin/backup.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/backup.sh"]
