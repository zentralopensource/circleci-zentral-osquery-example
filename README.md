# CircleCI Zentral osquery example

CircleCI project to manage a Zentral server osquery configuration using Terraform.

## Terraform state

### Backend

The Terraform state is managed using a S3 Bucket – see [terraform s3 backend documentation](https://developer.hashicorp.com/terraform/language/settings/backends/s3). You need to create a bucket and decide which key to use (filename) for the state object. The bucket name and key will be passed to the CircleCI workflow as environment variable.

### AWS authentication

#### AWS OIDC provider

To authenticate with AWS and give the CircleCI pipeline permission to use the state object in the S3 bucket, an OpenID Connect provider must be configured in AWS to verify the JSON tokens signed passed to the workflow by CircleCI. The tokens are exchanged against standard temporary AWS tokens that can be used by the Terraform S3 backend. See this [CircleCI blog post](https://circleci.com/blog/openid-connect-identity-tokens/) for more details.

#### AWS IAM role

A role needs to be created in AWS. This role will be assumed by the CircleCI workflow. Here is an example of the trust policy to use on the role (replace `CIRCLE_CI_ORGANIZATION_ID`, `CIRCLE_CI_PROJECT_ID` and the federated principal ARN by the correct values):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::AWS_ACCOUNT_ID:oidc-provider/XXXXXXXX"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.circleci.com/org/CIRCLE_CI_ORGANIZATION_ID:aud": "CIRCLE_CI_ORGANIZATION_ID"
                },
                "StringLike": {
                    "oidc.circleci.com/org/CIRCLE_CI_ORGANIZATION_ID:sub": "org/CIRCLE_CI_ORGANIZATION_ID/project/CIRCLE_CI_PROJECT_ID/user/*"
                }
            }
        }
    ]
}
```

This will restrict the access to the role to the given project within your CircleCI org.

#### AWS Bucket policy

The role you have just created needs to get access to the state object key within the S3 bucket. Here is an example of a S3 bucket policy you can use (replace `AWS_ACCOUNT_ID`, `CIRCLE_CI_AWS_ROLE`, `BUCKET_NAME`, `BUCKET_KEY` by the correct values):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::AWS_ACCOUNT_ID:role/CIRCLE_CI_AWS_ROLE"
                ]
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::BUCKET_NAME"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::AWS_ACCOUNT_ID:role/CIRCLE_CI_AWS_ROLE"
                ]
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::BUCKET_NAME/BUCKET_KEY"
        }
    ]
}
```

## State migration

If you already have a local Terraform state, you can migrate it to the s3 backend using the following command:

```bash
terraform init --migrate-state \
  --backend-config="bucket=$STATE_BUCKET_NAME" \
  --backend-config="key=$STATE_OBJECT_NAME"
```

Make sure you have valid `AWS_REGION` and `AWS_PROFILE` environment variables. You also need to get access locally to the S3 bucket. You could temporarily change the bucket policy and add the AWS principal you use to authenticate from your local machine. Once the migration is done, tighten the S3 bucket policy and remove the local Terraform state files.

## Zentral authentication

You also need Zentral credentials for the CircleCI workflow. In Zentral create a group with the required permissions, and create a service account, with an API token. Add the service account to the group.

## CircleCI project variables

|Variable|Value|
|---|---|
|AWS\_REGION|The AWS region|
|AWS\_ROLE\_ARN|The role that the CircleCI pipeline will assume|
|S3\_BACKEND\_BUCKET|The name of the bucket used by the Terraform S3 backend|
|S3\_BACKEND\_KEY|The key of the object used by the Terraform S3 backend|
|ZTL\_API\_BASE\_URL|The base URL for the Zentral API|
|ZTL\_API\_TOKEN|The Zentral API token|
