---
title: Guidance for Uploading Audiences created in AWS Clean Rooms to TikTok Ads
summary: "This Guidance assists AWS customers with automating the uploading of TikTok Ads with custom audience data for TikTok Advertiser. It explores the stages of activating custom audience segment data created in AWS to deliver personalized ads in TikTok."
published: true
hide_sidebar: false
sidebar: tiktok_sidebar
permalink: uploading-audiences-to-tiktok-ads.html
folder: guides
tags: document
layout: page
---

---

<!--# Guidance for Auploading Audiences created in AWS Clean Rooms to TikTok Ads

###### Author: Abhijit Rajeshirke

###### -->

## Overview

This Guidance assists AWS customers with automating the
uploader of TikTok Ads with custom audience data for TikTok
Advertiser. It explores the stages of uploading custom audience
segment data created in AWS to deliver personalized ads in TikTok.

The uploader for TikTok Ads allows you to use enriched data
in AWS to create targeted custom audiences in TikTok. With this
connector, you can leverage user profile data to create custom audiences
in TikTok in a custom file upload.

## Cost and licenses

No licenses are required to deploy this solution. There is no cost to
use this solution, but you will be billed for any AWS services or
resources that this solution deploys.

## Architecture overview

With the Uploader for TikTok Ads, using an event-based
serverless connector solution, you can securely ingest first party data
along with third party data to create custom audiences in TikTok.

<!---[](media/image1.png){width="7.0in" height="3.3534722222222224in"}-->
{% include image.html file="TikTok_IG/tiktok_Figure1.png" alt="reference architecture diagram" %}

*Figure 1 - Diagram for uploading TikTok Ads marketing campaign using AWS*

1.  TikTok access token and advertiser_id is securely updated in AWS
    Secrets Manager

2.  Custom audience data is uploaded in the Amazon Simpler Storage
    Service (Amazon S3) bucket's designated prefix (\<S3
    Bucket\>/tiktok/\<audiencename\>/\<format\>/custom_auidences.csv )
    in any of the Tiktok SHA256 supported formats shown below. The Amazon
    S3 bucket is encrypted using AWS Key Management Service (AWS KMS):

    -   EMAIL_SHA256

    -   PHONE_SHA256

    -   IDFA_SHA256

    -   GAID_SHA256

    -   FIRST_SHA256

3.  Amazon EvenBridge routes the Amazon S3 object event to Amazon Simple
    Queue Service (Amazon SQS), enabling support for API retry, replay,
    and throttling.

4.  Amazon Simple Queue Service (Amazon SQS) queue event triggers TikTok Audience Uploader and AWS
    Lambda function.

5.  The Audience Activation AWS Lambda function retrieves the access token
    and advertiser_id from AWS Secrets Manager and uploads the target
    custom audience to TikTok Ads. If uploaded audience is already
    present, activated Lambda function appends the audiences to current
    audience.

6.  TikTok Ads advertisers, agencies, or companies leverage
    this custom audience data as first party audience targeting.

## Security

When you build systems on an AWS infrastructure, security
responsibilities are shared between you and AWS. This shared model can
reduce your operational burden as AWS operates, manages, and controls
the components from the host operating system and virtualization layer
down to the physical security of the facilities in which the services
operate. For more information about security on AWS, refer to [AWS Cloud
Security](https://aws.amazon.com/security){:target="_blank"}.

### Amazon S3

Infrastructure components where user data flows through are encrypted using Server-Side Encryption
(SSE). Multiple Amazon S3 buckets are created for this solution, and they are encrypted using S3-SSE AES-256
encryption to secure user data.

### AWS KMS

This AWS service is used to encrypt the data stored in Amazon S3 and
Secrets Manager. In addition, AWS KMS is used to encrypt the data in
transit through Amazon EventBridge and Amazon SQS.

### AWS Secrets Manager

Secrets Manager helps encrypts secrets at rest using
encryption keys that you own and store in AWS KMS.

## Implementation steps

### Manual prerequisites

1.  Setup TikTok API for business developers by following documentation
    [here](https://ads.tiktok.com/marketing_api/docs?id=1735713609895937){:target="_blank"}.

2.  You will need a long-term access token (with Audience Management
    Permission of scope) and *advertiser_id* by following the TikTok
    Authentication API documentation
    [here](https://ads.tiktok.com/marketing_api/docs?id=1738373164380162){:target="_blank"}.

### Deploying the project with AWS Cloud Development Kits

The project code uses the Python version of the [AWS Cloud Development Kit](https://aws.amazon.com/cdk/){:target="_blank"} (AWS CDK). To execute the project
code, please ensure that you have fulfilled the [AWS CDK Prerequisites for Python](https://docs.aws.amazon.com/cdk/latest/guide/work-with-cdk-python.html){:target="_blank"}.

The project code requires that the AWS account is [bootstrapped](https://docs.aws.amazon.com/de_de/cdk/latest/guide/bootstrapping.html){:target="_blank"}
in order to allow the deployment of the AWS CDK stack.

### AWS CDK deployment

1. Navigate to project directory: ```cd [activation-connector-tiktok-ads](https://github.com/aws-samples/activation-connector-tiktok-ads)```

2. Install and activate a Python Virtual Environment: 
```python3 -m venv .venv```
```source .venv/bin/activate```

3. Install dependent libraries: ```python -m pip install -r requirements.txt```

### TikTok credentials

1.  Update the TikTok credentials in Secrets Manager. Secrets Manager
    *tiktok_activation_credentials* are created as part of AWS CDK
    deployment. Go to the Secrets Manager Console and select
    **tiktok_activation_credentials:**

<!---[](media/tiktok_Figure2.png){width="6.991666666666666in"
height="2.408333333333333in"}-->
{% include image.html file="TikTok_IG/tiktok_Figure2.png" alt="TikTok activation credentials" %}

*Figure 2 - Image TikTok Activation Credentials in Secrets Manager Console*

{:style="counter-reset:none"}
2.  Select **Retrieve secret value:**

<!---[](media/tiktok_Figure3.png){width="6.991666666666666in" height="0.575in"}-->
{% include image.html file="TikTok_IG/tiktok_Figure3.png" alt="retrieve secret value prompt" %}
*Figure 3- Image of Retrieve secret value prompt in UI*

{:style="counter-reset:none"}
3.  Add **ACCESS_TOKEN and ADVERTISER_ID** keys and corresponding Secret
    value retrieved from TikTok Authentication API:

<!---[](media/tiktok_Figure4.png){width="6.308333333333334in"
height="1.6916666666666667in"}-->
{% include image.html file="TikTok_IG/tiktok_Figure4.png" alt="Secret value fields" %}
*Figure 4- Image of Secret value fields*

### AWS CDK context

Update the cdk.context.json with the bucket name for TikTok custom
segment data:
```json
{
    "tiktok_data_bucket_name": "rajeabh-connector-data-tiktok-001"
}
```
### Bootstrap the account to setup CDK deployments in the Region
```
cdk bootstrap
```
Upon successful completion of cdk bootstrap, the project is ready to be
deployed:
```
cdk deploy
```
### Data Bucket Structure

Targeted custom audience segment data needs to be normalized and hashed
in the SHA256 format and uploaded in an Amazon S3 bucket. The Amazon S3
bucket and Prefix should be in this format
**S3bucket/tiktok/\<audience-segment-name\>/\<format-type\>/custom_audiences.csv**

Include these parameters:

-   **audience-segment-name** matches with the name of the audience in
    TikTok Ads Manager

-   **format-type** matches with any of the following TikTok SHA256
    supported format:

    -   email_sha256

    -   phone_sha256

    -   idfa_sha256

    -   gaid_sha256

    -   first_sha256

{: .note }
Format-type is NOT case sensitive. For example, you can give prefix name “email_sha256” or “EMAIL_SHA256” for uploading Custom Audiences segment emails encrypted with the SHA256 format. 

<!---[](media/tiktok_Figure5.png){width="7.0in" height="2.734722222222222in"}-->
{% include image.html file="TikTok_IG/tiktok_Figure5.png" alt="Amazon S3 bucket" %}
*Figure 5- Image of Amazon S3 bucket structure*

{: .important }
Protect your user data! Do not store it in client code or share it with users. 

### TikTok Data File Schema

TikTok API for Business supports custom audience uploads in the
following SHA256 encrypted formats. Refer to [TikTok API for Business](https://ads.tiktok.com/marketing_api/docs?id=1738855099573250){:target="_blank"} for
all supported types for [Custom File Upload](https://ads.tiktok.com/marketing_api/docs?id=1739566528222210){:target="_blank"}:

-   EMAIL_SHA256

-   PHONE_SHA256

-   IDFA_SHA256

-   GAID_SHA256

-   FIRST_SHA256

PHONE_SHA256 Example: Phone based in SHA256 format: *3d562b4ba5680ddba530ca888ec699e921b74fcbf5b89e34868d2c9afcd82fb9*

EMAIL_SHA256 Example: Email based in SHA256 format: *fd911bd8cac2e603a80efafca2210b7a917c97410f0c29d9f2bfb99867e5a589*

## Testing

1.  Copy test custom audiences file **from** GitHub:
    */test/tiktok/test_foodies_phone_sha256_audience.csv*

    **to:** *S3Bucket/tiktok/ foodies-custom-audience/phone_sha256/
test_foodies_phone_sha256_audience.csv*

{:style="counter-reset:none"}
2.  Verify Custom audience *foodies-custom-audience* is created in
    TikTok Ads Manager

{:style="counter-reset:none"}
3.  Verify Custom file is uploaded for audience
    *foodies-custom-audience* in TikTok Ads Manager.

{: .note }
If you upload audience with existing custom audience name, audience data will be appended to the existing custom audience.

> <!---[](media/tiktok_Figure6.png){width="6.991666666666666in" height="1.9916666666666667in"}-->

{% include image.html file="TikTok_IG/tiktok_Figure6.png" alt="TikTok Ads Manager" %}
*Figure 6 - TikTok Ads Manager showing audience date appended to existing custom audience*

## Cleanup

When you're finished experimenting with this solution, clean up your
resources by running the command: ```cdk destroy```

This command deletes resources deployed through the solution. The Secrets
Manager secret containing the manually added
**tiktok_activation_credentials** and CloudWatch log groups are retained
after the stack is deleted.

## Resources

1.  [TikTok for Business
    Account](https://ads.tiktok.com/marketing_api/docs?id=1738855099573250){:target="_blank"}
2.  [TikTok API for
    Business](https://ads.tiktok.com/marketing_api/docs?id=1735712062490625){:target="_blank"}
3.  [TikTok
    Audiences](https://ads.tiktok.com/marketing_api/docs?id=1739566496956417){:target="_blank"}
4.  [Upload
    Audiences](https://ads.tiktok.com/marketing_api/docs?id=1739940567842818){:target="_blank"}
5.  [TikTok Custom Audience Customer
    File](https://ads.tiktok.com/help/article?aid=6721963343558475781){:target="_blank"}

## Source Code

You can visit our [GitHub
repository](https://github.com/aws-samples/activation-connector-tiktok-ads){:target="_blank"} to
download the templates and scripts for this solution, and to share your
customizations with others.

## Document Revisions

 January 2023 - Initial Release

## Contributors

Author: Abhijit Rajeshirke



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

Any customer list output from your Amazon environment that you are seeking to activate through TikTok’s Custom Audiences will still need to adhere to TikTok’s Custom Audience terms, including verifying that data you share with TikTok does not include information about children, sensitive health or financial information, other categories of sensitive information. For full details on TikTok's Custom Audience terms please review: https://ads.tiktok.com/i18n/official/policy/custom-audience-terms.

## AWS glossary

For the latest AWS terminology, see the [AWS
glossary](https://docs.aws.amazon.com/general/latest/gr/glos-chap.html){:target="_blank"} in
the *AWS General Reference*.

