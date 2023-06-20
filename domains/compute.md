---
title: "Compute"
hide_sidebar: true
permalink: compute.html
has_toc: false
layout: home
nav_exclude: true
search_exclude: true
tags: domain
logo: Compute_32.svg
---
<div class="container">
<h1 style="margin-bottom: 2%" style="color:#6f6b6b">Implementation Guides for Compute</h1>
    <div class="row">
        {% assign sorted_pages = site.pages | sort: 'title' %}
        {% for page in sorted_pages %}
        {% for tag in page.tags %}
        {% if tag == "compute" %}
        <div class="col-md-3 card text-center" style="margin:5px">
                 <div class="card-body">
                     <p class="card-title">{{page.title}}</p>
                 </div>
                 <div style="padding-bottom:20px">
                    <a href="{{ page.url | absolute_url }}" class="btn btn-secondary">Learn More</a>
                 </div>
         </div>
         {% endif %}
         {% endfor %}
         {% endfor %}
    </div>
</div>