---
title: Guidance for Connecting Audiences to Amazon Marketing Cloud Uploader
summary: "This guide will help Amazon Marketing Cloud (AMC) users retrieve data
from AWS Clean Rooms as well as third-party data sources, such as
Salesforce Marketing Cloud, Adobe Experience Platform, and Google Cloud
Platform and import the data into AMC. "
published: true
sidebar: AdvertiserUploads_sidebar
permalink: advertising-marketing/connecting-audiences-to-amazon-marketing-cloud-uploader.html
tags: amt
layout: page
---

---

<!-- # Guidance for Connecting Audiences to Amazon Marketing Cloud Uploader  -->

This guide will help Amazon Marketing Cloud (AMC) users retrieve data
from AWS Clean Rooms as well as third-party data sources, such as
Salesforce Marketing Cloud, Adobe Experience Platform, and Google Cloud
Platform. The guide also explains how to import that data into AMC
using Amazon Marketing Cloud (AMC) Uploader from AWS.

## Implementation

**AWS Connectors**

AWS connectors are available to support data ingestion from external
third-party sources into AWS. These connectors bring data into an Amazon
Simple Storage Service (Amazon S3) bucket so AMC Uploader from AWS can
access the data. Once users make the data available and have formatted
it in accordance with the AMC file format requirements, AMC Uploader
from AWS imports the data into AMC. Data sources may include:

-   Salesforce Marketing Cloud Connector Solution

-   Adobe Experience Platform Connector Solution

-   Google Cloud Connector

**Importing data from** **AWS Clean Rooms** **to AMC**

AWS Clean Rooms helps customers and their partners match, analyze, and collaborate on their collective
datasets---without sharing or revealing underlying data. AWS Clean Rooms
supports exporting data that can be used to create datasets within AMC
using a <ins>LIST</ins> analysis rule on a configured table within a
collaboration.

{: .note }
*When communicating with your collaboration partner, ensure that
the data they are sharing is within the same region as your AMC
Instance. AWS Clean Rooms does not support cross-region data
collaborations.*

**Setting up the collaboration**

1.  Navigate to the AWS Clean Rooms service within the AWS Management
    Console

2.  Select **Create collaboration**

3.  Input a name for the collaboration and an optional description

4.  Set up the Members

    a.  Input a member display name for yourself

    b.  Input a member display name and AWS Account ID for each member
        you will be collaborating with

5.  Select yourself as the member who will be performing queries and
    receiving results

6.  Optional: Enable query logging or cryptographic computing

7.  Select **Create** and join collaboration

8.  Each member you invited will now need to accept the invitation to
    collaborate within their AWS Clean Rooms console.

**Configuring a table**

{: .note }
It's assumed that you already have your data within an S3 Bucket
within the same region as your AWS Clean Room and that you've already
configured a Glue Table that is maintaining the schema of your data.
<ins>This is a requirement before completing the next steps</ins>.

1.  Navigate to the **Configured Tables** section on the sidebar within the
    AWS Clean Rooms Console

2.  Select **configure new table**

3.  Select the relevant AWS Glue Database and Table

4.  Select which columns will be allowed within the collaboration. You
    can select all columns or individually select specific columns to be
    shared.

5.  Give the table a name

6.  Select **configure new table**

You must now configure an Analysis rule. An Analysis rule impacts how
the tables can be queried and which data will be exposed

1.  Locate the alert to configure an analysis rule (it may be at the top of the page). Select **Configure analysis rule** 

2.  Select **List** for the Type and use the **Guided flow** as the creation
    method

3.  Select **Next**

4.  Select a join control column that you have determined with your
    collaborators to use as a match key. You can select one or multiple columns.

5.  Select which columns you wish to expose to your collaborators as
    list controls

6.  Select **Next**

7.  Validate the information is correct on the review page. If
    everything looks good, select **Configure analysis rule**

**Associate your table to the collaboration**

Now that you've created a collaboration and configured your table, you
need to associate that table to the collaboration.

1.  Navigate to the collaboration that you've set up

2.  Navigate to the Tables tab and select **Associate table**

3.  Select the table that you just created

4.  Input a table name and optional description. Ensure that the table
    name is unique to the collaboration and that you do not overlap
    table names with your collaborators

5.  For Service access, you can either have the service provision a new
    IAM Role for you or you can create a new one separately using the
    policy document given on the page

6.  Select **Associate table**

By associating your table to your collaboration, you can
monitor the **Tables** tab to see when other collaborating members have
associated their tables. The other collaborators will need to follow the
same steps here to ensure that the proper data is being exposed and the same analysis rule is applied to the associated tables.

**Querying the collaboration and storing the results**

Once your collaborators have successfully set up their side of the
collaboration, you can start performing queries:

1.  Navigate to the collaboration and select the **Queries** tab

2.  You will be prompted to set up a query output location

    a.  Select the same S3 Bucket you used to store your first party
        data when deploying the AMC Uploader Solution. You should also
        set up a dedicated folder in that S3 Bucket for the AWS Clean
        Room query output.

    b.  <ins>Ensure that you select CSV as the output format</ins>

3.  You can now input your SQL query into the box and select **Run.** The
    results will be outputed into the console as well as within the S3
    Bucket and path you specified.

**Uploading your AWS Clean Rooms output to Amazon Marketing Cloud**

{: .note }
*Note: It is assumed that you've already deployed AMC Uploader
Solution. <ins>This is a requirement before completing the next
steps</ins>*

1.  Navigate to the AMC Uploader Solution web interface

2.  Select **Step 1** - Select file on the left side bar

3.  Select the file that was outputted from AWS Clean Rooms and select
    **Next**

4.  Input a name for the Dataset name and optional description

5.  Select **CSV** for the File format and **Dimension** for the Dataset
    type.

6.  Select Next

7.  Map the schema to the columns that were discovered within the file.

    a.  Ensure that if any column contains personally identfiable information (PII) data, that you specify
        PII as the Column Type and select the relevant PII type. This
        will ensure that this data is hashed prior to being uploaded to
        AMC.

    b.  Ensure that any column where you wish to perform an aggregate
        function is defined as a Metric column type

8.  Select **Next**

9.  Verify the data is correct and select **Submit**

Once submitted, a new dataset will be created within AMC and an AWS Glue
Job has been created to normalize and hash the data. You can monitor the
Glue Job by selecting it under **Phase 2: Datasets transformed.** 

Once the Glue Job has been completed, the data will be outputed into another S3
Bucket that the AMC Uploader Solution created. AMC will then access that
bucket and extract the data to be inserted into the newly created
Dataset within AMC. You can monitor that process as well in the **Phase 3: Datasets uploaded** section by selecting on the relevant Dataset in Phase 1

**Importing data from Salesforce Marketing Cloud (SFMC) to AMC using the SFMC Connector Solution**

When you deploy the SFMC Connector Solution, it will create multiple S3
buckets to handle the raw and transformed data. To upload the data into
AMC, you will be setting up an S3 Bucket Replication Rule to
automatically send the raw data that is imported to an S3 Bucket where
all of your first party data will live.

1.  Before deploying the solution, ensure that you select a region that
    matches the same region your AMC Instance is deployed in. For North
    America, this is us-east-1 and for EMEA/APAC, this is eu-west-1. You
    can find the region your instance is deployed in by visiting the
    instance info page within the AMC Console.

2.  Deploy the Solution using the provided CloudFormation template.
    Follow the implementation guide's deployment steps for more
    information. Ensure that <ins>Subscriber</ins> is the data you
    are importing from SFMC.

3.  Ensure that the AppFlow that was created as part of the SFMC
    solution has been executed and is importing data. If not, trigger
    the job to run or set up the flow on a schedule to import data on a
    cadence you specify.

4.  Once the solution is deployed, go to the Outputs tab of the
    CloudFormation template and save the value of
    <ins>BucketInboundData</ins>. This is where your raw data will be
    saved to and where we will need to replicate data from.

5.  Select the link specified in the BucketInboundData value. This will
    take you directly to the created S3 Bucket.

6.  Select on the bucket name in the breadcrumb at the top of the page,
    it should start with **sfmc-connector-inboundbucket.**

7.  Select the **Management** tab and scroll down to **Replication rules**

8.  Select **Create replication rule**

9.  Enter a name such as AMCDataReplication

10. Data coming into the InboundBucket will be saved with the prefix
    "sfmc-connector-flow/". Enter "sfmc-connector-flow/" (without
    quotes) into the Prefix box.

11. For the Destination, select a bucket that you will use to store your
    first party data that will be accessed by the AMC Uploader. If you
    do not have a bucket, create a new one. Make sure the bucket is in
    the same region as your AMC Instance. Ensure that versioning is
    enabled in the destination bucket as it is required for replication.
    If versioning is not enabled on the destination bucket, you can
    enable it directly from the **Replication** set up page within the
    Console.

12. Next, select an existing IAM Role to allow the replication, or
    select **Create new role**

13. The SFMC connector uses an AWS KMS key to encrypt the raw data. Check the
    box for **Replicate objects encrypted with AWS KMS** and specify the
    KMS key that the files are encrypted with. If you are unsure which
    KMS key is used, browse to one of the files in the S3 bucket that
    was imported from SFMC and locate the **Encryption key ARN**

14. Leave all other options as default

15. Select **Save.** If versioning is not enabled in the source bucket, the
    console may prompt you to enable versioning. You can do so by
    selecting the enable version control button.

16. Once saved, you will be on the Batch Operations Job page

17. Uncheck **Generate completion report**

18. Leave all other details default

19. Select **Save**

20. The job will run immediately and the data will be replicated to your
    AMC first party data S3 Bucket

**Uploading your AWS Clean Rooms output to Amazon Marketing Cloud**

{: .note }
*Note: It is assumed that you've already deployed AMC Uploader Solution.<ins>This is a requirement before completing the next steps</ins>*

1.  Navigate to the AMC Uploader Solution web interface

2.  Select **Step 1** - Select file on the left side bar

3.  Select the file that was outputted from the SFMC Connector and select
    **Next**

4.  Input a name for the **Dataset** name and optional description

5.  Select **CSV** for the File format and **Dimension** for the Dataset
    type.

6.  Select **Next**

7.  Map the schema to the columns that were discovered within the file.

    a.  Ensure that if any column contains PII data, that you specify
        PII as the Column Type and select the relevant PII type. This
        will ensure that this data is hashed prior to being uploaded to
        AMC.

    b.  Ensure that any column where you wish to perform an aggregate
        function is defined as a Metric column type

8.  Select **Next**

9.  Verify the data is correct and select **Submit**

Once submitted, a new dataset will be created within AMC and an AWS Glue
Job has been created to normalize and hash the data. You can monitor the
Glue Job by selecting it under **Phase 2: Datasets transformed.** 

Once the Glue Job is complete, the data will be outputed into another S3
Bucket that the AMC Uploader Solution created. AMC will then access that
bucket and extract the data to be inserted into the newly created
Dataset within AMC. You can monitor that process as well in the **Phase 3: Datasets uploaded** section by selecting on the relevant Dataset in **Phase 1.**

## Formatting data for AMC Uploader from AWS 

When the data is imported into an Amazon S3 bucket, it must be in one of
the accepted formats in the AMC data upload file format requirements.
Additionally, the data must be in a single file. AMC Uploader from AWS
will take care of AMC formatting requirements, including hashing
specific columns, flagging data as specific PII, and segmenting data into separate files by time
windows.

AMC supports two types of datasets: (1) Dimension and (2) Fact. Users
must ensure the data meets the relative requirements. See the AMC Fact
vs. Dimension Datasets section below for more information about the
differences between these two dataset types.

## AMC file format requirements

**AMC Uploader from AWS requirements**

The AMC Uploader from AWS requires data to be in a single file in either
CSV or JSON format. As of 2023, the AMC Uploader from AWS does not
support multiple files in partition format.

**CSV file requirements**

CSV files must be **UTF-8 encoded** and comma delimited. In Microsoft
Excel, save the file in a "CSV UTF- 8 (comma-delimited)" format. When
CSV files are uploaded, AMC will automatically convert data to the
corresponding column type. For example, if "12423.56" is contained in
the CSV file and is mapped to a **DECIMAL** type column, AMC will coerce
the string value contained in the CSV file to the appropriate column
type.

**JSON file requirements**

JSON files must contain one object per row of data. JSON arrays should
not be used. Table 1 is an example of the accepted JSON format:
```json
{"name": "Product A", "sku": 11352987, "quantity": 2, "pur_time": "2021-06-23T19:53:58Z"} 
{"name": "Product B", "sku": 18467234, "quantity": 2, "pur_time": "2021-06-24T19:53:58Z"} 
{"name": "Product C", "sku": 27264393, "quantity": 2, "pur_time": "2021-06-25T19:53:58Z"} 
{"name": "Product A", "sku": 48572094, "quantity": 2, "pur_time": "2021-06-25T19:53:58Z"} 
{"name": "Product B", "sku": 18278476, "quantity": 1, "pur_time": "2021-06-26T13:33:58Z"}
```


*Table 1- Example of the accepted JSON format*
## AMC Data Types, Timestamp, and Date Formats

Dataset columns can be defined with the data types listed in Table 2.
Carefully review the accepted formats for **TIMESTAMP** and **DATE**
columns. If values in CSV / JSON data do not meet the accepted format,
the upload may fail.

Ensure all values in CSV / JSON data confirm the specified data type and
format before uploading. Where possible, string values will be coerced
to the corresponding numerical type and vice-versa, but no guarantees
are made on the casting process.

| Data Type | Format | Example |
|-------------|-------------|-------------|
| STRING | UTF-8 encoded character data | My string data |
|DECIMAL  | Numerical with two floating point level precision  | 123.45 |
INTEGER (int 32-bit) | 32-bit numerical, no floating points  | 12345
LONG (int 64-bit) | 32-bit numerical, no floating points | 1233454565875646
TIMESTAMP | yyyy-MM-ddThh:mm:ssZ | 2021-08-02T08:00:00Z
DATE | yyyy-MM-dd | 8/2/2021

*Table 2 - Data Types and Formats*

## AMC fact vs dimension datasets

Before data can be uploaded, a table (also referred to as a dataset)
must be created to store that data. As mentioned above, AMC supports two
types of datasets: fact and dimension. The implications for each dataset
type is detailed in Table 3:

| Dataset Type | Usage | Requires Timestamp Column  | Requires Partition Type (Period) | 
|-------------|-------------|-------------|-------------|
| Fact | Time series data | Yes | Yes
|Dimension  | Static data  | No | No




*Table 3 - Differences between Fact and Dimension Datasets*

**Fact datasets**

Fact datasets should be used for time-series data, meaning data where
each row is associated with a corresponding date or timestamp. When
defining a fact dataset, it is mandatory to designate one column as the
main event time.\
\
Because fact datasets are used to store time-series data, the data files
must be partitioned by a unit of time before uploading to AMC. The
partition type (also referred to as a period) should be specified on the
dataset, and the options are per-minute, per-hour, per-day, and
per-week. The partition type informs how often the data can be queried.
For example, per-week partitioned data cannot be queried at the daily
level, and per-day partitioned data cannot be queried at the hourly
level.\
\
When data is uploaded to a fact dataset, each upload is performed
according to a specific period of time. This is how AMC determines which
data to include when performing queries. The AMC Uploader from AWS
separates the partitions.

**Dimension datasets**

Dimension datasets can be used to upload static data or any information
that is not time-bound. Examples include customer relationship
management (CRM) audience lists, campaign metadata, mapping tables, and
product metadata, such as a table mapping ASINs to external product
names or sensitive cost-of-goods-sold data. When data is uploaded to a
dimension dataset, AMC will always use the most recent file uploaded,
which is known as the full-replace method of updating data.

Dimension datasets do not require a main event time column or uploaded
files to be partitioned.
