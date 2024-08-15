# Database Backup Service

This repository provides a Docker image and Kubernetes CronJob configuration to back up a PostgreSQL database to a Minio bucket.

## Docker Image

The Docker image includes `pg_dump` for PostgreSQL backup and `mc` (Minio Client) to upload the backup to a Minio bucket.

### Build Docker Image

To build the Docker image, run the following command:

```bash
docker build -t ${IMAGE_NAME}:${TAG} .
```

## Kubernetes CronJob

The Kubernetes CronJob is configured to run the backup script at a scheduled time.

### Example CronJob YAML

Create a file named `postgres-backup-cronjob.yaml` with the following content:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
spec:
  schedule: "0 2 * * *"  # Runs every day at 2am
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: postgres-backup
            image: IMAGE_NAME:TAG
            env:
            - name: POSTGRES_HOST
              value: "your-postgres-host"
            - name: POSTGRES_PORT
              value: "5432"
            - name: POSTGRES_DB
              value: "your-database-name"
            - name: POSTGRES_USER
              value: "your-database-user"
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: your-postgres-secret
                  key: password
            - name: MINIO_ENDPOINT
              value: "your-minio-endpoint"
            - name: MINIO_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: your-minio-secret
                  key: access-key
            - name: MINIO_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: your-minio-secret
                  key: secret-key
            - name: MINIO_BUCKET
              value: "your-minio-bucket"
            - name: BACKUP_PATH
              value: "you"
          restartPolicy: OnFailure
```

### Deploy CronJob

To deploy the CronJob to your Kubernetes cluster, run:

```bash
kubectl apply -f postgres-backup-cronjob.yaml
```

## Testing the Backup

To test the backup process locally, you can run the Docker container with the necessary environment variables:

```bash
docker run --rm \
  -e POSTGRES_HOST=your-postgres-host \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_DB=your-database-name \
  -e POSTGRES_USER=your-database-user \
  -e POSTGRES_PASSWORD=your-database-password \
  -e MINIO_ENDPOINT=your-minio-endpoint \
  -e MINIO_ACCESS_KEY=your-minio-access-key \
  -e MINIO_SECRET_KEY=your-minio-secret-key \
  -e MINIO_BUCKET=your-minio-bucket \
  -e BACKUP_PATH=your-backup-folder \
  ${IMAGE_NAME}:${TAG}
```

This command will create a backup of the PostgreSQL database and upload it to the specified Minio bucket.

## Conclusion

This setup ensures that your PostgreSQL database is regularly backed up to a Minio bucket using a Kubernetes CronJob. Modify the backup schedule and other configurations as needed to fit your requirements.
