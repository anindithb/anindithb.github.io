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
    <div class="row">
        {% assign sorted_pages = site.pages | sort: 'title' %}
        {% for page in sorted_pages %}
        {% for tag in page.tags %}
        {% if tag == "document" %}
        <div class="col-md-3 card text-center" style="margin:5px">
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