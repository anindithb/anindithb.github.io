---
title: Guidance for Connecting Data from Google Analytics to AWS Clean Rooms
summary: "This Guidance shows how to use Google Analytics 4 data in AWS to make marketing decisions and set up marketing channels with custom audience profiles."
published: true
hide_sidebar: false
sidebar: google_sidebar
permalink: advertising-marketing/connecting-data-from-google-analytics.html
folder: guides
tags: amt
layout: page
---

---


## Overview

This Guidance demonstrates ingesting Google Analytics 4 data
into AWS and activating marketing channels with customized audience profiles for marketing analytics. It explores each stage of building this solution and covers data ingestion, transformation, data cataloging, and analysis to prepare it for consumption using AWS native services.

## Cost and licenses

No licenses are required to deploy this solution. There is no cost to
use this solution, but you will be billed for any AWS services or
resources that this solution deploys.

You'll need the no-cost Google BigQuery Connector for AWS Glue from [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-sqnd4gn5fykx6?sr=0-1&ref_=beagle&applicationId=AWSMPContessa){:target="_blank"}
to connect AWS Glue jobs to BigQuery.

## Architecture Overview

This sample solution will help customers securely ingest and analyze
first-party and third-party data. Marketers can further use this
information to activate marketing channels with customized segments.

<!--[](media/image1.png){width="6.021142825896763in"
height="3.9515923009623797in"}-->

{% include image.html file="Google/google_figure1.png" %}
***Figure 1** -- Architecture overview of a sample solution*

1.  Amazon EventBridge scheduled rule starts and runs the AWS Step
    Functions workflow.

2.  Google Cloud Big Query access credentials are securely stored in
    AWS Secrets Manager and encrypted with AWS Key Management Service (AWS KMS).

3.  AWS Glue job will ingest data using the [AWS Marketplace Google BigQuery Connector for AWS Glue](https://aws.amazon.com/marketplace/pp/prodview-sqnd4gn5fykx6){:target="_blank"}.
    The connector simplifies the process of connecting AWS Glue jobs to
    extract data from BigQuery. This AWS Glue job will encrypt,
    normalize, and hash the data.

4.  The output of the AWS Glue job will be written to the target Amazon Simple Storage Service (Amazon
    S3) bucket:prefix location in parquet format. The output file will be
    partitioned by date and encrypted with AWS KMS.

5.  AWS Glue Crawler job is initiated to "refresh" the table
    definition and its associated meta-data in the AWS Glue Data
    Catalog.

6.  The Data Consumer queries the data output with Amazon Athena.

## Security

When you build systems on AWS infrastructure, security responsibilities
are shared between you and AWS. This shared model can reduce your
operational burden as AWS operates, manages, and controls the components
from the host operating system and virtualization layer down to the
physical security of the facilities where the services operate. For more
information about security on AWS, refer to [AWS Cloud Security](https://aws.amazon.com/security){:target="_blank"}.

### Amazon S3

Infrastructure components in the Guidance where user data flows through are encrypted using Server-Side Encryption
(SSE). Multiple Amazon S3 buckets are created for this solution and they are encrypted using S3-SSE AES-256
to secure user data.

### AWS KMS

This AWS service is used to encrypt the data stored in Amazon Kendra and
Amazon OpenSearch Service. In addition, AWS KMS is used to encrypt the
data in transit through Amazon Simple Notification Service (Amazon SNS) and
Amazon Simple Queue Service (Amazon SQS).

### Secrets Manager

Secrets Manager will encrypt secrets at rest using
encryption keys you own and store in AWS KMS.

## Implementation steps

Follow the step-by-step instructions in this section to configure the
solution into your account.

### Deploying the Project with AWS Cloud Development Kits

The project code uses the Python version of the [AWS Cloud Development Kit](https://aws.amazon.com/cdk/){:target="_blank"} (AWS CDK). To start the project
code, please ensure that you have fulfilled the [AWS CDK Prerequisites for Python](https://docs.aws.amazon.com/cdk/latest/guide/work-with-cdk-python.html){:target="_blank"}.

The project code requires that the AWS account is [bootstrapped](https://docs.aws.amazon.com/de_de/cdk/latest/guide/bootstrapping.html){:target="_blank"}
in order to allow the deployment of the AWS CDK stack.

### AWS CDK Deployment

navigate to project directory:

```cd aws-glue-connector-ingestion-ga4-analytics```


install and activate a Python Virtual Environment:

```python3 -m venv .venv```

```source .venv/bin/activate```


install dependent libraries:

```python -m pip install -r requirements.txt```

### AWS CDK Context Parameters Configuration

Update the cdk.context.json
```json
{
    "job_name": "bigquery-analytics",
    "data_bucket_name": "your-s3-bucket-name",
    "dataset_id": "Big Query Dataset ID",
    "parent_project": "GCP Project ID",
    "connection_name": "bigquery",
    "filter": "",
    "job_script": "job-analytics-relationalize-flat.py",
    "schedule_daily_hour": "3",
    "glue_database": "gcp_analytics",
    "glue_table": "ga4_events",
    "timedelta_days": "1"
}
```
### Context Parameter Summary

1.  job_name: name of the AWS Glue job

2.  data_bucket_name: bucket name for the data and AWS Glue job script

3.  dataset_id: BigQuery Dataset ID for the Google Analytics 4 export

4.  parent_project: GCP Project ID

5.  connection_name: AWS Glue Connection name

6.  filter: not currently used, however, used for query filtering

7.  job_script - job-analytics-relationalize-flat.py: this included AWS
    Glue script will pull yesterday's data from BigQuery

8.  schedule_daily_hour - - default 3 AM: daily schedule hour of the
    job runs to get yesterday's analytics data

9.  glue_database: AWS Glue database name

10. glue_table: AWS Glue table name

11. timedelta_days: Number of days back to pull events. 0 = today, 1 =
    yesterday

### Bootstrap the account to set up AWS CDK deployments in the region

```cdk bootstrap```

**Upon successful completion of cdk bootstrap, the project is ready to
be deployed.**

```cdk deploy```

**Exporting Data from Google Analytics 4 Properties to BigQuery**

Follow the setup from [Exporting Data from Google Analytics 4 Properties to BigQuery](https://support.google.com/analytics/answer/9358801?hl=en){:target="_blank"}

Subscribe to the Google BigQuery Connector for AWS Glue

Follow the below steps for subscribing to the [Google BigQuery Connector for AWS Glue](https://aws.amazon.com/marketplace/pp/prodview-sqnd4gn5fykx6?sr=0-1&ref_=beagle&applicationId=GlueStudio){:target="_blank"} in the AWS Marketplace

1.  Choose to **Continue to Subscribe**.

2.  Review the terms and conditions, pricing, and other details.

3.  Choose to **Continue to Configuration**.

4.  For the Fulfillment option, choose the **AWS Glue Version** (3.0).

5.  For Software Version, choose your software version

6.  Choose to **Continue to Launch**

7.  Under **Usage** instructions, review the documentation, then choose
    to **Activate the Glue connector from AWS Glue Studio**.

8.  You're redirected to AWS Glue Studio to create a Connection.

9.  For Name, enter a name for your connection (for example, bigquery).

10. For AWS Secret, choose **bigquery_credentials**.

11. Choose to **Create a connection and activate the connector**.

12. A message appears that the connection was successfully created, and
    the connection is now visible on the AWS Glue Studio console.

**Setup Google Cloud Platform (GCP) Access Credentials**

1.  Create and Download the service account credentials JSON file from
    Google Cloud. [Create credentials for a GCP service account](https://developers.google.com/workspace/guides/create-credentials#service-account){:target="_blank"}

2.  base64 encode the JSON access credentials. For Linux and Mac, you
    can use base64 <<service_account_json_file>> to output the file
    contents as a base64-encoded string

**Add GCP Credentials in Secrets Manager**

In Secret Manager, paste the credentials into the secret
**bigquery_credentials** credentials value with the base64 encode access
credentials:

<!--[](media/image2.png){width="7.0in" height="0.6513888888888889in"}-->
{% include image.html file="Google/google_figure2.png" %}
***Figure 2** --Secrets Manager*

<!--[](media/image3.png){width="7.0in" height="1.5708333333333333in"}-->

{% include image.html file="Google/google_figure3.png" %}
***Figure 3** -- Location to paste the credentials*

## Testing

1.  Manually initiate the AWS Step Functions named **gcp-connector-glue**

2.  After the Step Functions is completed, go to Athena

    1.  Select Data source: **AwsDataCatalog**

    2.  Select the Database: **ga4_analytics**

    3.  Query SELECT * FROM your ga4_events

<!--[](media/image4.png){width="7.0in" height="3.734722222222222in"}-->
{% include image.html file="Google/google_figure4.png" %}
***Figure 4** -- Athena query editor*

## Sample Queries

Sample queries are available in the [GitHub repository](https://github.com/aws-samples/aws-glue-connector-ingestion-ga4-analytics){:target="_blank"}

## Cleanup

When you are finished experimenting with this solution, clean up your
resources by running the command:

```cdk destroy```

This command deletes resources deploying through the solution. The
Secrets Manager secret containing the manually added GCP Secret and
Amazon CloudWatch log groups are retained after the stack is deleted.

## Resources

1.  [Google BigQuery Connector for AWS Glue](https://aws.amazon.com/marketplace/pp/prodview-sqnd4gn5fykx6?sr=0-1&ref_=beagle&applicationId=GlueStudio){:target="_blank"}

2.  [Exporting Data from Google Analytics 4 Properties to BigQuery](https://support.google.com/analytics/answer/9358801?hl=en){:target="_blank"}

3.  [Migrating data from Google BigQuery to Amazon S3 using AWS Glue custom connectors](https://aws.amazon.com/blogs/big-data/migrating-data-from-google-bigquery-to-amazon-s3-using-aws-glue-custom-connectors/){:target="_blank"}

4.  [Create credentials for a GCP service account](https://developers.google.com/workspace/guides/create-credentials#service-account){:target="_blank"}

## Source Code

You can visit the [GitHub repository](https://github.com/aws-samples/aws-glue-connector-ingestion-ga4-analytics){:target="_blank"} to
download the templates and scripts for this solution

## Revisions
  November 2022                       Initial Release


## Contributors

The following individuals contributed to this document:

-   Brian Maguire

-   Anurag Singh

## AWS Glossary

For the latest AWS terminology, see the [AWS glossary](https://docs.aws.amazon.com/general/latest/gr/glos-chap.html){:target="_blank"} in
the *AWS General Reference* guide.

## Notices

Customers are responsible for making their own independent assessment of
the information in this document. This document: (a) is for
informational purposes only, (b) represents AWS current product
offerings and practices, which are subject to change without notice, and
(c) does not create any commitments or assurances from AWS and its
affiliates, suppliers or licensors. AWS products or services are
provided "as is" without warranties, representations, or conditions of
any kind, whether express or implied. AWS responsibilities and
liabilities to its customers are controlled by AWS agreements, and this
document is not part of, nor does it modify, any agreement between AWS
and its customers.

Google Analytics is a trademark of Google LLC




