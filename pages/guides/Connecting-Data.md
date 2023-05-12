---
title: Guidance for Connecting Data to AWS Clean Rooms
summary: "This Guidance helps advertisers, publishers, and
data providers in the advertising and marketing industry provision data for an AWS Clean Rooms collaboration."
published: true
hide_sidebar: false
sidebar: connectingdata_sidebar
permalink: connecting-data-clean-rooms.html
folder: guides
tags: document
layout: page
---

---

This Guidance helps advertisers, publishers, and
data providers in the advertising and marketing industry provision data for an AWS Clean Rooms collaboration.
Data Connectors capture best practices for connecting to specific types
of data sources, landing data in AWS, transforming, and making data
available for a data collaboration.

## Reference Architecture for Data Connector

This reference architecture provides an efficient way to ingest and package data for AWS Clean Rooms data collaboration.

{% include image.html file="Connecting_data/connecting-data-clean-rooms.png" alt="architecture" %}
*Figure 1 - Diagram of AWS Clean Rooms data connectors* 

## Implementation Examples for common sources of advertising and marketing data

### Salesforce Marketing Cloud

Salesforce Marketing Cloud provides a native integration to Amazon
Simple Storage Service (Amazon S3). Data stored in custom objects can be
exported to Amazon S3 using Automation Studio.

### Adobe Experience Platform

Adobe Experience Platform provides a native integration to Amazon S3
service. Data stored in custom objects can be exported to Amazon S3
using Automation Studio. Refer to [this
guidance](https://aws.amazon.com/solutions/guidance/connecting-data-from-adobe-experience-platform){:target="_blank"}
for provisioning data stored in Adobe Experience Platform for AWS Clean
Rooms data collaboration.

### Google Cloud Platform

Data stored Google Big Query can be ingested in to Amazon S3 using AWS
Glue service. Refer to [this
guidance](https://aws.amazon.com/solutions/guidance/connecting-data-from-google-analytics){:target="_blank"}
for provisioning data stored in Google Analytics for AWS Clean Rooms data collaboration.

## Further Strategies to consider for data ingestion

The processing steps in the data connector can be broadly divided into two phases:

1.  Data ingestion

2.  Data preparation/transformation

The data ingestion strategy varies widely given the broad list of data sources and their integration capabilities. These data sources are divided into 5 categories based on their deployment architecture, including:

1.  Third Party SaaS solutions: Salesforce Marketing Cloud, Adobe
    Experience Platform exposing an HTTP API

2.  Third Party SaaS solutions: Salesforce Marketing Cloud, Adobe
    Experience Platform having capabilities to export data in to Amazon
    S3 directly

3.  Relational Data stores hosted in public cloud: Google Cloud Platform
    (Google file storage, Google Big Query)

4.  Data made available in file format on an SFTP server

5.  Data made available in a public cloud object storage (Azure, Google)

This reference architecture captures the AWS services to consider for each category of the data sources. 

{% include image.html file="Connecting_data/General-connector-ref-arch (2).png" alt="architecture of other AWS services" %}

*Figure 3 - Diagram of AWS services for consideration when building with this Guidance* 


Once data is ingested into Amazon S3, a common pattern displayed in the aforementioned reference architecture can be used to transform and package data for AWS Clean Rooms data collaboration.
