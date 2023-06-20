---
title: Guidance for Launching a Simple E-commerce Website with WordPress on AWS
summary: "Launch a simple website on AWS in minutes with e-commerce and analytics
capabilities, without having to delve into complex coding or configuration."
published: true
hide_sidebar: false
sidebar: eccomercewithwordpress_sidebar
permalink: retail/launching-simple-ecommerce-website-with-wordpress-on-aws.html
folder: guides
tags: retail
layout: page
---

---

<!-- **Description:** -->
Launch a simple website on AWS in minutes with e-commerce and analytics
capabilities, without having to delve into complex coding or
configuration. Small- and medium-sized businesses (SMBs) can use this
Guidance Implementation Guide to quickly deploy a website with WordPress
for website content management, WooCommerce for e-commerce capabilities,
and WordPress Statistics (WP Statistics) to monitor your site analytics.
With this Guidance, you can launch a secure website and manage your
design and content. The website is deployed on Amazon Lightsail, which
gives you standard, predictable pricing per month.

## Benefits

By using this Guidance, you will gain the following benefits:

-   **Quickly launch e-commerce websites:** Launch e-commerce websites
    quickly, and manage them using intuitive plug-ins like WordPress and
    WooCommerce.
    
-   **Auto setup and configuration:** The setup of the website instance,
    security, login, and plug-ins are all handled automatically, without
    any manual technical work.

-   **Predicable monthly pricing:** This solution is deployed on
    Lightsail and provides low, monthly, predictable pricing.

**Architecture diagram
Figure 1** shows the diagram for this Guidance.

{% include image.html file="Wordpress/Wordpress_Figure1.png" alt="architecture" %}
<!---![](media/image1.png){width="5.284615048118985in"
height="3.560904418197725in"}-->

Figure 1: Diagram for Launching a Simple E-Commerce Website with WordPress on AWS

## Architecture workflow

1.  Access the AWS CloudFormation template [here](https://github.com/aws-solutions-library-samples/guidance-for-simple-ecommerce-website-on-aws/blob/main/deployment/sws_template_mlp.deployment){:target="_blank"} and deploy it in your AWS
    Console [here](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks){:target="_blank"}. The template will handle all of the setup and access and
    provide you with a URL to access your new website. The
    CloudFormation was tested in US-East-1 AWS Region, and the guidance
    can be used only in US-East-1 based on Lightsail distribution
    availability. For more details, see [AWS::Lightsail::Distribution](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lightsail-distribution.html){:target="_blank"} in the [AWS CloudFormation User Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html){:target="_blank"}.

2.  Before launching the CloudFormation template, create your Admin user
    name and Admin password and store it in AWS Secrets Manager [here](https://us-east-1.console.aws.amazon.com/secretsmanager/listsecrets?region=us-east-1){:target="_blank"}. The
    name of the secret should be **WordpressAdminCredentials.** The two
    keys for username and password should be name **AdminUsername** and
    **AdminPassword,** respectively.

3.  The website is created utilizing LightSail's instance and is
    initialized with standard configurations such as Linux OS, the
    latest version of WordPress, and other plug-ins to enable e-commerce
    and analytics.

    a.  Your website instance on AWS is priced at a standard \$5
        USD/month, with 1GB of RAM, 1 virtual CPU, 40 GB of storage, and
        2 TB of data transfer. These costs do not account for any
        additional WordPress plug-ins you may install.

    b.  Once the instance is created, you are responsible for managing
        the installed plug-ins like WordPress, WooCommerce, Elementor,
        and WP Statistics.

4.  An Amazon CloudFront distribution is automatically created within
    Lightsail, which accelerates delivery of your website content and
    assets globally and provides distributed-denial-of-service (DDoS)
    protection.

5.  Once the CloudFormation Template has created the stack, you can find
    the URL of your website in the Outputs section of the CloudFormation
    console.

    a.  In the **Output** tab in the CloudFormation Stack, open the
        **DistributionDetails** URL in a new tab. See Figure 2 for an
        example screenshot of where to find your URL.

    b.  Click the **Default domain** link shown in the distribution.
        Example link: [https://d1gb5spb######.cloudfront.net/](https://d1gb5spb/######.cloudfront.net/){:target="_blank"}

    c.  Append **wp-login.php** to the URL of the **Default domain** link:
        Example link:
        [https://d1gb5spb######.cloudfront.net/wp-login.php](https://d1gb5spb/######.cloudfront.net/wp-login.php){:target="_blank"}

    d.  Log in using the username and password from Secrets Manager.

{% include image.html file="Wordpress/Wordpress_Figure2.png" alt="screenshot" %}
<!--![](media/image2.png){width="6.5in" height="2.1819444444444445in"}--->

Figure 2: Screenshot of Outputs Tab Hosting the URL

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e.  Your website will have the following plug-ins enabled so you can customize your website:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I. WordPress plug-in to create your website using various themes

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;II. WooCommerce plug-in to create your online e-commerce store

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;III. Elementor plug-in to provide you more control over customizing your website layout and formatting

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;IV. WP Statistics plug-in that provides insights on website analytics, so you can track visits to your new website

{:style="counter-reset:none"}

6.  Your website instance is now created, and you can log in to the website with your username and password, that you provided in Step 2.
a.  Log in to your website using the WordPress Login URL. For example, if your website is [www.example.com](http://www.example.com){:target="_blank"}, you can log in at [www.example.com/wp-login.php](http://www.example.com/wp-login.php){:target="_blank"}. You simply need to append "/wp-login.php" to the end of your URL or domain name.

7.  You can also register a new domain and transfer it to AWS in order to access your website through a domain name.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a.  To use your own domain name, register your domain name and ensure the domain is active.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I.  Log in to the LightSail console, and access the [Domains and DNS](https://lightsail.aws.amazon.com/ls/webapp/home/domains){:target="_blank"} section from the main Lightsail page.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;II. Create a new Domain Name System (DNS) Zone, as shown in the screenshot in Figure 3.
{% include image.html file="Wordpress/Wordpress_Figure3.png" alt="screenshot" %}

<!--![](media/image3.png){width="3.4918482064741907in" height="1.7847222222222223in"}-->
Figure 3: Screenshot of "Create DNS zone" function.

{:style="counter-reset:none"}
8.  Enter the domain you have registered, and select Create DNS Zone.

{% include image.html file="Wordpress/Wordpress_Figure4.png" alt="screenshot" %}
<!--![](media/image4.png){width="4.469231189851269in" height="1.3135531496062993in"}-->

Figure 4: Screenshot of Domain Registration

{:style="counter-reset:none"}
9.  Go to the Hosting provider where you registered the domain (if
    outside of AWS), and create CNAME records provided after you select
    "Create DNS Zone".

{% include image.html file="Wordpress/Wordpress_Figure5.png" alt="screenshot" %}
<!--[](media/image5.png){width="4.507905730533683in"height="1.4148906386701663in"}-->

Figure 5: Screenshot of CNAME Records

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a)  For example, if you are using an external hosting provider, you can create CNAME records as shown in Figure 6, to ensure the domain is redirected to your existing website.

{% include image.html file="Wordpress/Wordpress_Figure6.png" alt="screenshot" %}
<!--[](media/image6.png){width="6.146307961504812in"height="1.8055555555555556in"}-->

Figure 6: Screenshot Showing How to Create CNAME Records

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b)  For more information, refer to the webpage: [Creating a DNS zone to manage your domain's DNS records in Lightsail](https://lightsail.aws.amazon.com/ls/docs/en_us/articles/lightsail-how-to-create-dns-entry){:target="_blank"}.

{:style="counter-reset:none"}    
10. Check and verify that website traffic is routing correctly to your Lightsail instance.