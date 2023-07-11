# CircleCI Zentral osquery example

CircleCI project to manage a Zentral server osquery configuration using Terraform.

## State migration

If you already have a local Terraform state, you can migrate it to the s3 backend using the following command:

```bash
terraform init --migrate-state \
  --backend-config="bucket=$STATE_BUCKET_NAME" \
  --backend-config="key=$STATE_OBJECT_NAME"
```

Make sure you have valid `AWS_REGION` and `AWS_PROFILE` environment variables.

## CircleCI project variables

|Variable|Value|
|---|---|
|AWS\_REGION|The AWS region|
|AWS\_ROLE\_ARN|The role that the CircleCI pipeline will assume|
|S3\_BACKEND\_BUCKET|The name of the bucket used by the Terraform S3 backend|
|S3\_BACKEND\_KEY|The key of the object used by the Terraform S3 backend|
|ZTL\_API\_BASE\_URL|The base URL for the Zentral API|
|ZTL\_API\_TOKEN|The Zentral API token|