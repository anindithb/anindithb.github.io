---
title: Guidance for Connecting Data from Salesforce Marketing Cloud to AWS Clean Rooms
summary: "This Guidance demonstrates how to import audience and campaign data from Salesforce Marketing Cloud (SFMC) to Amazon S3 to securely collaborate with partners and data providers in an AWS Clean Rooms environment."
published: false
hide_sidebar: false
sidebar: SFMC-IG_sidebar
permalink: advertising-marketing/connecting-data-from-salesforce-marketing-cloud.html
folder: guides
tags: amt
layout: page
---

---

<!-- # Guidance for Connecting Data from Salesforce Marketing Cloud&reg; to AWS Clean Rooms -->

## Scenario 

ACME, an AWS customer, uses Salesforce Marketing Cloud&reg; (SFMC) to manage
their marketing campaigns and subscriber data. The Chief Marketing
Officer (CMO) of ACME wants to enrich certain set of ACME subscribers
with additional 3^rd^ party data attributes which are already shared by
the 3^rd^ party data providers for consumption in AWS Clean Rooms.
CMO tasks the data engineering team to have the SFMC dataset available
in AWS Clean Rooms for profile enrichment.

The ACME data engineering team evaluates this request and defines the
following steps:

**Data export from Salesforce Marketing Cloud**

1.  Gain access to SFMC account and define the subscriber query using
    automation studio.

2.  Setup a periodic task that will execute this query and export the
    result set to the ACME AWS account.

Data ingestion and security in AWS

{:start="3"}
3.  Create an Amazon Simple Storage Service (Amazon S3) repository that
    can receive the data files from SFMC.
{:start="3"}

{:start="4"}
4.  Ensure that the data is protected and encrypted as per ACME security
    policies and best practices.
{:start="4"}

**Data Transformation**

{:start="5"}
5.  Invoke a process to transform the ingested data into a format that
    can be used within the AWS Clean Rooms service. 
{:start="5"}

**Automation**

{:start="6"}
6.  Automate the end-to-end process to improve efficiency and
    productivity of the team.
{:start="6"}

The purpose of this Guidance is to assist ACME to import their
SFMC subscriber data into their AWS account at a regular cadence and
thereafter, process, normalize and transform the raw data using AWS
native services for consumption within an AWS Clean Rooms environment.

## Implementation Details

In this Guidance, we will ingest subscriber data from Salesforce Marketing Cloud (SFMC) utilizing Salesforce Automation Studio into your Amazon Simple Storage Service (Amazon S3) bucket. The Guidance will demonstrate how to read this data, normalize, and process it to make it compatible within AWS Clean Rooms.

<!---[](media/image1.png){width="6.5in" height="3.704861111111111in"}-->
{% include image.html file="salesforce/salesforce_figure1.png" %}
*Figure 1: Reference Architecture to ingest SFMC data into AWS*

## Data Ingestion

To ensure that you are capturing all available data, create two separate
automations. The first automation will be a backfill to export the last
90 days of data to an Amazon S3 bucket. The second automation will be a scheduled
rolling file of yesterday's data.

### Set up an Amazon Simple Storage Service File Location

To set up Amazon S3 as a file location, you will need to complete a few
prerequisite steps including:

1.  Obtaining an AWS Access Key & Secret Access Key by creating a
    programmatic user

2.  Creating an Amazon S3 bucket

3.  Creating IAM Policy granting access to the newly created Amazon S3 bucket

4.  Assigning the IAM Policy to the newly created user

These steps ensure that Salesforce Marketing Cloud can access your AWS
account and can only push files to a specific Amazon S3 bucket.

**Creating an Amazon S3 Bucket**

1.  Sign in to the [AWS Management Console](<https://console.aws.amazon.com/s3/) and open the Amazon S3 console

2.  On the Amazon S3 console, choose **Buckets** in the navigation pane

3.  Choose **Create bucket**

4.  For **Bucket name**, enter ```sfmc-data-<random-number>```

5.  Select **Block all public access**

6.  Enable SSE-S3 based bucket encryption

7.  Select **Create bucket**.

Once the bucket is created, create three folders within the bucket.
1. Select the bucket and Select **Create a folder**.
2. For **Folder name**, enter ```landing``` and Select SSE-S3 as the server-side encryption.

Repeat the above two steps to create two additional folders -- **raw** and **archive**.

<!--**![](media/image2.png){width="4.680371828521435in"
> height="5.211719160104987in"}-->
{% include image.html file="salesforce/salesforce_figure2.png" %}
> *Figure 2: Creating an Amazon S3 bucket*

### Creating an IAM Policy for user access to the Amazon S3 bucket

8.  Open the [IAM console](<https://console.aws.amazon.com/iam/>).

9.  On the navigation menu, choose **Policies**.

10. Select **Create policy**

11. Input the policy JSON into the **JSON** tab. This
    gives the user the ability to upload objects to the newly created
    bucket.

12. Select **Next: Tags**

13. (Optional) Add any relevant tags to this policy

14. Select **Next: Review**

15. Input a **Name** such as "SalesforceS3Access"

16. Select **Create Policy**

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SFMCListBuckets",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<your bucket name"
            ]
        },
        {
            "Sid": "SFMCUploadObjects",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::<your bucket name/*"
            ]
        }
    ]
}
```

### Creating a user and obtaining credentials

1.  Open the [IAM console](https://console.aws.amazon.com/iam/)

2.  On the navigation menu, choose **Users**.

3.  Select **Add users**

4.  Input a user **Name**

5.  Select **Access key -- Programmatic access** for the **AWS access type**

6.  Select **Next: Permissions**

7.  Select the **Attach existing policies directly** tab

8.  Search for the policy created in the previous step (Example:SalesforceS3Access)

9.  Select the checkbox next to the policy to assign it to the user

10. Select **Next: Tags**

11. (Optional) Fill in any relevant tags

12. Select **Next: Review**

13. Review the configuration and select **Create User**

14. Select **Show** in the Secret access key column to reveal the Secret Access Key

15. Save the Access key ID and Secret access key to a safe place to be used in the next section

###  Create the Amazon S3 File Location in Salesforce Marketing Cloud 

The first step within SFMC is to create a destination file location to send the files to. It is required that you completed the prior steps before completing this step.

1.  Hover over your name on the upper right and select **Setup**

2.  In the Data Management Section on the left sidebar, select **File
    Locations**

3.  Select **Create**

4.  Complete the information in the Properties section

    a.  Name -- A unique name

    b.  External key (Optional) -- Used as part of the API

    c.  Description -- Any helpful details to identify this location

5.  For the location type, Select **Amazon Simple Storage Service**

6.  Complete the location Information

    a.  **Authorization Type** -- Select **Access Key**

    b.  **AWS Bucket Name** -- The bucket name you created earlier in
        > this guide

    c.  **AWS Relative Path** -- Input: landing

    d.  **Access Key ID** -- This is the Access Key you generated
        > earlier in the guide

    e.  **Secret Access Key** -- This is the Secret Access Key you
        > generated earlier in the guide

    f.  **Region Name** -- Select the region name that your bucket was
        > created in

7.  Select **Save**

<!--[](media/image3.png){width="6.268055555555556in"
height="2.8118055555555554in"}-->
{% include image.html file="salesforce/salesforce_figure3.png" %}
*Figure 3 -- SFMC setup S3 File Location*

### Create a journey in Automation Studio 

To set up an export from Salesforce Marketing Cloud to Amazon S3, you
will need to use Automation Studio. Automation Studio is located under
**Journey Builder > Automation Studio**.

1.  Navigate to Automation Studio by Selecting **Journey Builder** and
    Selecting **Automation Studio**

2.  From the Automation Studio Overview page, Select **New Automation**

3.  For Starting Source, drag **Schedule** to the Starting Source column
    and Select **Configure**

4.  Select a Start Date/Time, Time Zone, and how often it will repeat

5.  Select **Done**

**Step 1 -- Data Extract**

For the first step, we will be using the Data Extract activity to
extract data from SFMC.

1.  Drag the **Data Extract** activity to the area labeled "Drop
    Activity on the canvas"

2.  On the newly created Step 1 column for Data Extract, Select
    **Choose** to Select a Data Extract configuration

3.  Select **Create New Data Extract Activity** and follow the steps
    below for configuration of a new Data Extract Activity.

**Data Extract Activity Configuration**

1.  Input a **Name** such as "Extract Data"

2.  Input a **File Naming Pattern** such as ```%%Year%%%%Month%%%%Day%%_Extract.zip```

3.  Select **Tracking Extract** for **Extract Type**

4.  Select **Next**

5.  Select **Rolling Range**

6.  Set the date range to 1 day

7.  Input * into **Account IDs**

8.  Leave all other fields in the left column as default

9.  On the right column, Select the following checkboxes:

    -   Extract Subscribers

    -   Include All Subscribers

10. Select **Next**

11. Verify the details look correct, and Select **Finish**

**Step 2 -- File Transfer**

For this step, we will be taking the data that was extracted from the
first step and transferring it to an Amazon S3 Bucket that you
configured.

1.  Drag the **File Transfer** activity to the area labeled "Step 2"

2.  On the newly created File Transfer activity, select **Choose**

3.  Select **Create New File Transfer Activity**

4.  Input a **Name** such as "Transfer to S3"

5.  Select **Move a File From Safehouse**

6.  Select **Next**

7.  Input the same File Naming Pattern you used in the last step

8.  For the **Destination**, Select the Amazon S3 location you created in the
    Setup section

9.  Select **Next**

10. Review the information and Select **Finish**

<!--[](media/image4.png){width="6.268055555555556in" height="3.34375in"}-->
{% include image.html file="salesforce/salesforce_figure4.png" %}
*Figure 4 - Complete workflow*

**Step 3 -- Test the workflow**

After all of the steps have been configured, the workflow should look
like Figure 4. The next step is to test the workflow to ensure it works
and the data is available in the S3 Bucket.

**Test and run the automation**

1.  On the top right corner, Select **Save**

2.  In the dialogue box that pops up, input a **Name**

3.  Select **Save**

4.  Once saved, Select **Run Once** in the top right corner

5.  On the upper left, Select **Select All Activities** to Select all
    steps in the workflow

6.  Select **Run** on the upper right

7.  On the Run Once Confirmation, leave everything default and Select
    **Run Now**

8.  Wait for the workflow to complete and then log into your S3 bucket
    to verify the file has been delivered

## Data Processing 

Once the SFMC subscriber data lands in your Amazon S3 bucket, a daily
job will decrypt, normalize and hash the personally identifiable
information (PII) for AWS Clean Rooms consumption.

**1.  Decrypt SFMC data file(s) using AWS Lambda function**

AWS Lambda function will decrypt the SFMC subscriber file(s) using the
AWS KMS APIs and write the decrypted raw file(s) to a separate raw/
prefix within the same Amazon S3 bucket.

> Note: AWS Lambda IAM role will need appropriate permissions to
> read/write from Amazon S3 and AWS KMS

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::[bucket name]",
                "arn:aws:s3:::[bucket name]/*"
            ]
        }
    ]
}

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "kms:Decrypt",
            "Resource": "arn:aws:kms:us-east-1:[account-id]:key/[KMS key id]"
        }
    ]
}
```

<!--[](media/image5.jpg){width="2.8953488626421695in"
height="1.9773118985126859in"}-->

{% include image.html file="salesforce/salesforce_figure5.jpg" %}
*Figure 5: AWS Lambda function decrypts the encrypted SFMC files*

{:start="2"}
**2.  Data Exploration using AWS Glue DataBrew**
{:start="2"}

In this Guidance, you will use AWS Glue DataBrew to explore the
incoming data and create recipe to clean and normalize the data.

> **Note**: While other AWS services can be used to perform these tasks,
> AWS Glue DataBrew is chosen to demonstrate the ease of manipulating
> the data visually using the AWS Glue DataBrew service.

1.  Sign in into the AWS console as a user with the appropriate
    permissions to create IAM user and access keys

2.  Navigate to AWS Glue DataBrew
    ([https://console.aws.amazon.com/databrew/](https://console.aws.amazon.com/iam/))

3.  Select **Create project**

4.  Provide the name of the project

5.  Select '**Create new recipe**' and provide a name

6.  Choose '**New dataset'** and Select Amazon S3 as your source

7.  Provide the path as follows: ```s3://[bucket name]/raw/<.*>.csv```

This will ensure that all file(s) in the landing/ folder will be picked
up for processing.

<!--[](media/image6.png){width="6.5in" height="4.410416666666666in"}-->
{% include image.html file="salesforce/salesforce_figure6.png" %}
*Figure 6: AWS Glue DataBrew -- Create new dataset*

{:start="8"}
8.  Select **CSV** as the file type and **treat first row as header.**
{:start="8"}

{:start="9"}
9.  Provide the appropriate tags,
{:start="9"}

{:start="10"}
10. Choose the appropriate IAM role (or create one if it does not exist)

    -   Your IAM user needs permission to access the AWS Glue DataBrew
        from [AWS Console](https://docs.aws.amazon.com/databrew/latest/dg/setting-up-iam-policy-for-databrew-console-access.html)

    -   [IAM permissions](https://docs.aws.amazon.com/databrew/latest/dg/setting-up-iam-policy-for-data-resources-role.html) for AWS Glue DataBrew to access the data resources on your behalf
{:start="10"}

{:start="11"}
11. Create project.
{:start="11"}

Once the project is created, you will see a visual editor with a sample
of 500 records. At this stage, you can add various data transformation
steps in recipe for data cleansing, normalization and PII handling.

<!--[](media/image7.png){width="2.8333333333333335in"
height="2.4027777777777777in"}-->
{% include image.html file="salesforce/salesforce_figure7.png" %}
*Figure 7: AWS DataBrew recipe to transform, normalize and mask
sensitive data*

Once all the steps have been completed, publish the recipe. This will
create a version of the recipe.

Select **Create Job** to run the recipe on the entire dataset and
generate an output.

1.  Provide the job name

2.  Under the **Job output settings** create Output 1 as follows:

    -   Amazon S3 | Parquet file format | Snappy compression (if you do
        not have an Amazon S3 output location, you can create one at this
        step).

    -   Provide Amazon S3 output location.

    -   Select on the **settings** for Output 1

        -   Replace output files for each job run if you get a full data
            refresh on a daily basis.

        -   Provide appropriate tags.

        -   Select the IAM role that was previously used while creating the
            AWS Glue DataBrew project. This role will need permissions to
            read the source Amazon S3 data and write the transformed data
            back to specified output location.

<!--[](media/image8.png){width="6.5in" height="3.954861111111111in"}
![](media/image9.png){width="4.7141119860017495in"
height="4.0029800962379705in"}-->
{% include image.html file="salesforce/salesforce_figure8.png" %}
*Figure 8: AWS DataBrew- Create job*

-   Create and run job

Navigate to the **JOBS** section in the left pane of AWS console and
wait until the job you just created runs successfully.

<!--[](media/image10.png){width="6.5in" height="1.5125in"}-->
{% include image.html file="salesforce/salesforce_figure9.png" %}
*Figure 9: AWS Glue DataBrew- Recipe job status*

Once the job is successfully completed, navigate to the output Amazon S3
location to verify the transformed data file.

<!--[](media/image11.png){width="6.5in" height="2.3006944444444444in"}-->
{% include image.html file="salesforce/salesforce_figure10.png" %}
*Figure 10: Amazon S3- Transformed SFMC data*

**3. AWS Lambda function for cleanup**

You can create an AWS Lambda function to perform cleanup tasks which
includes moving the file(s) from landing/ and raw/ prefix to an archive/
prefix folder within the same Amazon S3 bucket.

> Note: AWS Lambda IAM role will need appropriate permissions to
> read/write from Amazon S3.

<!--[](media/image12.jpg){width="2.7441863517060368in"
height="1.8785706474190726in"}-->
{% include image.html file="salesforce/salesforce_figure11.jpg" %}
*Figure 11: AWS Lambda function to archive files*

## Data Catalog

In order to use Salesforce Marketing Cloud data in AWS Clean Rooms
environment, the transformed data needs to be registered with AWS Glue
Data Catalog.

**1.  Create AWS Glue Data Catalog database**

You will create a database within AWS Glue Data Catalog

1.  Sign in into AWS console and navigate to[AWS Glue Data Catalog](https://console.aws.amazon.com/glue)

2.  Select **Databases** under the **Data catalog** section in the left menu.

3.  Select **Add database** and provide a name.

{:start="2"}
**2.  Create AWS Glue Crawler**
{:start="2"}

You can use AWS Glue Crawler to populate AWS Glue Data Catalog by
crawling the transformed files in Amazon S3 bucket. Upon completion, AWS
Glue Crawler will create respective tables in your data catalog. This
table can be referenced within the AWS Clean Rooms environment.

1.  Sign in into AWS console and navigate to [AWS Glue Data Catalog](https://console.aws.amazon.com/glue).

2.  Select **Crawlers** under the **Data catalog** section in the left
    panel.

3.  Select **Create crawler**.

4.  Provide a unique crawler name and add appropriate tags.

5.  Add a data store
6.  Enter **S3** and provide output bucket location:

<!--[](media/image13.png){width="4.125in" height="6.458333333333333in"}-->
{% include image.html file="salesforce/salesforce_figure12.png" %}
*Figure 12: AWS Glue Data Catalog- Add crawler data source*


{:start="7"}
7.  Choose an IAM Role or have AWS Glue create a role for you by
    Selecting **Create new IAM role.**
{:start="7"}

{:start="8"}
8.  In the **Set output and scheduling** step Select your target
    database that you create in Step 1 earlier. Select Crawler schedule
    to run **On demand**. We will be automating the entire workflow
    using AWS Step Functions in the later section.
{:start="8"}

<!--[](media/image14.png){width="6.5in" height="3.696527777777778in"}-->
{% include image.html file="salesforce/salesforce_figure13.png" %}
*Figure 13: AWS Glue Data Catalog- Configure crawler output and
schedule*

{:start="9"}
9.  Review and **Create crawler**.
{:start="9"}

{:start="10"}
10.  Run Crawler to populate AWS Glue Data Catalog table.
{:start="10"}

<!--[](media/image15.png){width="6.5in" height="1.0638888888888889in"}-->
{% include image.html file="salesforce/salesforce_figure14.png" %}
*Figure 14: AWS Glue Data Catalog- Run crawler*

{:start="11"}
11. Once the crawler runs successfully, Select **Databases** under **Data Catalog** to verify AWS Glue Data Catalog table is created.
{:start="11"}

**3.  Verification**

You can further verify that the table has been successfully created in
AWS Glue Data Catalog by running a query in Amazon Athena.

1.  Navigate to **Amazon Athena Query Editor** in your AWS Console

2.  Select **AwsDataCatalog** as the Data source

3.  Select your AWS Glue Data Catalog database

4.  Run a Select query against your table to verify the results.

## Automation using AWS Step Functions and Amazon EventBridge

To automate the entire solution, you will use AWS Step Functions. AWS
Step Functions will orchestrate various steps to decrypt and process the
data during a daily scheduled run and then will initiate an AWS Glue
Crawler job. Once the AWS Glue crawler job completes, it will send a
notification to the Amazon Simple Notification Service (Amazon SNS)
topic to notify you of data availability for consumption in AWS Clean Rooms.

**1.  Create AWS Step Functions**

1.  Navigate to **Step Functions** in your AWS Console.

2.  Select **Create state machine.**

3.  Design your workflow visually with a **Standard** state machine.

4.  Draw your state machine definition in the visual editor as shown below with the correct configurations.

<!--[](media/image16.png){width="6.5in"
height="5.464583333333334in"}-->
{% include image.html file="salesforce/salesforce_figure15.png" %}
*Figure 15: AWS Step Functions- Visual
editor configuration*

{:start="5"}
5.  Assign appropriate tags.
{:start="5"}

{:start="6"}
6.  Select an IAM role or have the AWS Step Functions create one with
    correct permissions. Here are some sample permissions that Step
    Functions will require for its execution.
{:start="6"}

Ability to publish to Amazon SNS topics. This include both errored and success notification topics:
```json
 {
     "Version": "2012-10-17",
     "Statement": [
         {
             "Sid": "VisualEditor0",
             "Effect": "Allow",
             "Action": "sns:Publish",
             "Resource": [
                 "arn:aws:sns:us-east-1:[accountid]:sfmc-error-topic",
                 "arn:aws:sns:us-east-1:[accountid]:sfmc-success-topic"
             ]
         }
     ]
 }
```
Ability to invoke Lambda functions:
```json
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Sid": "VisualEditor0",
             "Effect": "Allow",
             "Action": "lambda:InvokeFunction",
             "Resource": [
                 "arn:aws:lambda:us-east-1:[accountid]:function:sfmc-decrypt-files:*",
                 "arn:aws:lambda:us-east-1:[accountid]:function:sfmc-cleanup-tasks:*"
             ]
         }
     ]
 }
```
Ability to start AWS Glue DataBrew job:
```json
 {
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": [
                 "databrew:startJobRun",
                 "databrew:listJobRuns",
                 "databrew:stopJobRun"
             ],
             "Resource": [
                 "arn:aws:databrew:us-east-1:[accountid]:job/sfmc-job"
             ]
         }
     ]
 }
```
Ability to start AWS Glue Crawler and the APIs for crawler status check:
```json
 {
     "Version": "2012-10-17",
     "Statement": [
         {
             "Sid": "VisualEditor0",
             "Effect": "Allow",
             "Action": [
                 "glue:GetCrawler",
                 "glue:StartCrawler"
             ]
             "Resource": "arn:aws:glue:us-east-1:[accountid]:crawler/sfmc-subscriber-crawler"
         }
     ]
 }
```
{:start="7"}
7.  Save the Step Functions definition.
{:start="7"}


**2. Error Handling within the AWS Step Functions**

Each step within the Step Functions will have a "catch-ALL" mechanism
to trap all errors and report them. For this Guidance, you are not
setting up any retry logic.

Example of a catch-ALL for a given step:

```json
"Glue DataBrew StartJobRun": {
    "Type": "Task",
    "Resource": "arn:aws:states:::glue:startJobRun.sync",
    "Parameters": {
        "JobName": "sfmc-job"
    },
    "Next": "StartCrawler",
    "Catch": [
        {
            "ErrorEquals": [
                "States.ALL"
            ],
            "Next": "SNS Error Handling Notification"**
        }
    ]
}

```
In the above snippet, any error state will result in a notification being sent to the error handling Amazon SNS topic that will further inform all the subscribers.

### State machine details

This section describes setting up state machine for your workflow in
details.

**1.  AWS Lambda - Decrypt CSV files**

Provide the ARN of the lambda function created in previous steps that will decrypt the incoming SFMC files and place them in the raw/ Amazon S3 bucket location.

For this Guidance, you will catch ALL errors and send a notification to an Amazon SNS topic for notification. Additionally, these errors will also be captured and logged within AWS CloudWatch Log Groups.

<!--[](media/image17.png){width="3.1609109798775155in"
height="5.620718503937008in"}-->
{% include image.html file="salesforce/salesforce_figure16.png" %}
*Figure 16: AWS Step Functions- Decrypt CSV files configuration*

**2. AWS Glue DataBrew StartJobRun to transform the data for AWS Clean Rooms consumption**

-   Provide the name of DataBrew Job that you had created earlier. You
    can also find it from AWS DataBrew console and Selecting JOBS from
    left panel.

-   Select **Wait for task to complete** checkbox to make sure the step
    machine resume execution once the task is completed successfully.

For this Guidance, you will catch ALL errors and send a notification to an Amazon SNS topic for notification. Additionally, these errors will be captured and logged within AWS CloudWatch Log Groups.

<!--[](media/image18.png){width="3.6666666666666665in"
height="5.958333333333333in"}-->
{% include image.html file="salesforce/salesforce_figure17.png" %}
*Figure 17: AWS Step Functions- Start DataBrew job configuration*

{:start="3"}
**3.  AWS Glue StartCrawler to populate Data Catalog with latest data**
{:start="3"}
-   Provide the name of the glue crawler previously created; You can
    also find it from AWS Glue console and Selecting Crawlers from left
    panel.

    Error Handling: For this guidance, you will catch ALL errors and send a
    notification to an Amazon SNS topic for notification. Additionally,
    these errors will also be captured and logged within AWS CloudWatch Log
    Groups.

>  **Note**: We will NOT check the wait for callback option to avoid writing custom callback function. Instead, we will rely on the native APIs of AWS Glue Crawler to poll for status within the Step Functions

<!--[](media/image19.png){width="3.5555555555555554in"
height="5.236111111111111in"}-->
{% include image.html file="salesforce/salesforce_figure18.png" %}
*Figure 18: AWS Step Functions- Start Glue crawler configuration*

**4.  AWS Glue GetCrawler status**

This task fetches the meta information from your AWS Glue crawler including its current state. If the current state is RUNNING OR STOPPING, it will wait for a configured amount of time and fetch the information once again. This will continue until the AWS Glue crawler status is READY.

Error Handling: For this Guidance, you will catch ALL errors and send a notification to an Amazon SNS topic for notification. Additionally, these errors will also be captured and logged within AWS CloudWatch Log Groups.

<!--[](media/image20.png){width="3.638888888888889in"
> height="5.694444444444445in"}-->
{% include image.html file="salesforce/salesforce_figure19.png" %}
*Figure 19: AWS Step Functions- Get Glue crawler status configuration*

**5.  Choice state**

Create rules to check status of crawler run:

<!--[](media/image21.png){width="5.0in" height="6.291666666666667in"}-->
{% include image.html file="salesforce/salesforce_figure20.png" %}
*Figure 20: AWS Step Functions- Create rules to check crawler status*

{:start="6"}
**6.  Wait state**
{:start="6"}

If the GetCrawler status is RUNNING or STOPPING, the Step Functions will wait for a configured time of 30 seconds, and will check the status once again. If the status of the crawler is in any other state, it will move to the next state function, otherwise it will continue to wait and check for the status again.

<!--[](media/image22.png){width="4.027777777777778in"
> height="4.444444444444445in"}-->
{% include image.html file="salesforce/salesforce_figure21.png" %}
*Figure 21: AWS Step Function- Configure wait state*

{:start="7"}
**7.  Invoke AWS Lambda function to perform cleanup tasks**
{:start="7"}

Provide the ARN of the Lambda function created previously that is responsible for performing cleanup activities.

For this Guidance, you will catch ALL errors and send a notification to an Amazon SNS topic for notification. Additionally, these errors will also be captured and logged within AWS CloudWatch Log Groups

<!--[](media/image23.png){width="3.6805555555555554in"
> height="5.416666666666667in"}-->
{% include image.html file="salesforce/salesforce_figure22.png" %}
> *Figure 22: AWS Step Functions- Invoke lambda to perform cleanup tasks*

{:start="8"}
8.  Publish to Amazon SNS topic upon successful execution
{:start="8"}

Select the appropriate topic in the configuration panel of the step
function:

<!--[](media/image24.png){width="3.7222222222222223in"
height="5.236111111111111in"}-->
{% include image.html file="salesforce/salesforce_figure23.png" %}
> *Figure 23: AWS Step Function- SNS success topic configuration*

{:start="9"}
9.  Publish all errored tasks to Amazon SNS topic
{:start="9"}

<!--[](media/image25.png){width="3.6805555555555554in"
height="5.263888888888889in"}-->
{% include image.html file="salesforce/salesforce_figure24.png" %}
*Figure 24: AWS Step Functions- SNS Errored topic configuration*

## Schedule the AWS Step Functions using Amazon EventBridge rule

Create a rule in Amazon EventBridge to invoke AWS Step Functions to start
the pipeline on a daily schedule.

1.  Sign in into AWS console and navigate to the Amazon EventBridge page

2.  Select **Create rule**

3.  Provide a rule name and Select **Schedule** as the rule type

4.  Select schedule pattern as **A fine-grained schedule**

5.  Provide the cron expression as ```0 0 * * ? *```

This will run the job daily at midnight (UTC time zone)

<!--[](media/image26.png){width="5.652777777777778in"
height="5.097222222222222in"}-->
{% include image.html file="salesforce/salesforce_figure25.png" %}
*Figure 25: Amazon EventBridge- Define schedule*

{:start="6"}
6.  Select AWS Service and **Step Functions state machine** as the target.
    Select the Step Functions:
{:start="6"}

<!--[](media/image27.png){width="5.638888888888889in"
height="5.958333333333333in"}-->
{% include image.html file="salesforce/salesforce_figure26.png" %}
*Figure 26: Amazon EventBridge -Select target*

{:start="7"}
7.  Provide appropriate tags
{:start="7"}

{:start="8"}
8.  Create rule
{:start="8"}

This Amazon EventBridge rule will invoke the AWS Step Functions daily to
normalize and transform the incoming subscriber data from SFMC for clean
room consumption.

### Summary

This Guidance provides assistance to ACME data engineers to
setup an automated data export from the Salesforce Marketing Platform
and transform the data so it is available for business users for AWS Clean Rooms consumption. 

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
Salesforce, the Salesforce logo, and any other Salesforce trademark are trademarks of Salesforce.com, Inc., and are used here with permission.
