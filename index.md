---
title: "Implementation Guides"
hide_sidebar: true
permalink: index.html
has_toc: false
layout: home
nav_exclude: true
search_exclude: true
---
<div class="container">
<h1 style="margin-bottom: 2%" style="color:#6f6b6b">Browse Implementation Guides by Industry & Technology</h1>
    <div class="row">
        {% assign sorted_pages = site.pages | sort: 'title' %}
        {% for page in sorted_pages %}
        {% for tag in page.tags %}
        {% if tag == "domain" %}
        <div class="col-md-3 card text-center" style="margin:5px">
                  <img src="images/icons/{{page.logo}}" style="max-width: 40%; margin: auto; margin-top: 20px" class="card-img-top img-fluid" alt="...">
                 <div class="card-body">
                     <p class="card-title">{{page.title}}</p>
                 </div>
                 <div style="padding-bottom:20px">
                    <a href="{{ page.url | remove: "/" }}" class="btn btn-secondary">Learn More</a>
                 </div>
         </div>
         {% endif %}
         {% endfor %}
         {% endfor %}
    </div>
</div>