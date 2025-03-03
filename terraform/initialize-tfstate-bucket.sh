#/bin/bash

export GOOGLE_APPLICATION_CREDENTIALS=test-project-7a895ad12eed.json

gcloud storage buckets create gs://test-project-tfstate --location=us-central1 --uniform-bucket-level-access

gcloud storage buckets add-iam-policy-binding gs://test-project-tfstate \
--member="serviceAccount:test-service-account@test-project.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"
