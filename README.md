# Google Cloud Run SQL Backup

Cloud run job to backup a Cloud SQL instance to a GCS bucket.

Commands:

After running `gcloud builds submit` to build & deploy the container, run the following command to schedule running the backup job
Remember to change the `--location`, `--oauth-service-account-email` and `--uri` to match your environment.
Also make sure service account has the correct permissions to run the job.

### Note you can also use the Cloud Console to create the job. It it easier

```bash
gcloud scheduler jobs create http cloudsqlbackup-schedule \
--location europe-west1 \
--schedule "0 0 * * *" \
--uri https://europe-north1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/taikuri/jobs/cloudsqlbackup:run \
--oauth-service-account-email X@developer.gserviceaccount.com \
--oauth-token-scope https://www.googleapis.com/auth/cloud-platform
```

### Create bucket

```bash
gcloud storage buckets create gs://tietokanta-backups \
--enable-autoclass \
--location europe-north1 \
--public-access-prevention
```

## Edit bucket flags to enable object versioning and lifecycle management

Lifecycle management is used to delete old backups if there are more than 365 backups in the bucket
or if the backups are older than 365 days. (manages costs)

```bash
gcloud storage buckets update gs://tietokanta-backups --versioning --lifecycle-file bucket-lifecycle-config.json
```
