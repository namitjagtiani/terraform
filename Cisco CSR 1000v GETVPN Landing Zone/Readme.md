# Table of Contents

- [Cisco CSR 1000v GETVPN Landing Zone Deployment](#cisco-csr-1000v-getvpn-landing-zone-deployment)
  * [Overview](#overview)
  * [Design](#design)
  * [Dependencies](#dependencies)
    + [The Module has the following dependencies](#the-module-has-the-following-dependencies)
  * [Components](#components)
    + [The Module deploys infrastructure across the following regions](#the-module-deploys-infrastructure-across-the-following-regions)
      - [Australia SouthEast](#australia-southeast)
        * [VNETs](#vnets)
        * [App Services](#app-services)
        * [Database](#database)
      - [Australia East](#australia-east)
      - [Australia Central](#australia-central)
    + [The Module deploys the following](#the-module-deploys-the-following)
  * [Caveats](#caveats)
  * [References](#references)
  * [Using The Module](#using-the-module)
    + [Plugins](#plugins)
    + [Todos](#todos)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


# Cisco CSR 1000v GETVPN Landing Zone Deployment

## Overview

This module deploys a Cisco CSR 1000v based landing zone in Microsoft Azure

## Design

> GETVPN Landing Zone: High Level
![](https://github.com/namitjagtiani/terraform_azure_network_automation/blob/master/Cisco%20CSR%201000v%20GETVPN%20Landing%20Zone/Images/High%20Level.png?raw=true)


> GETVPN Landing Zone: Detailed
![](https://github.com/namitjagtiani/terraform_azure_network_automation/blob/master/Cisco%20CSR%201000v%20GETVPN%20Landing%20Zone/Images/Detailed.png?raw=true)


------------
## Dependencies

### The Module has the following dependencies
  -
  -

------------
## Components

### The Module deploys infrastructure across the following regions

+ #### Australia SouthEast
  + ##### VNETs
    + ##### Transit Services VNET
      + 1 x Azure Internal Load Balancer
      + 3 x Cisco CSR 1000v routers
        + 2 x GETVPN Group Members
        + 1 x Key Server
    + ##### Private Endpoint VNET
      + 
  + ##### App Services
    + Dummy Web App Service running on ASP.NET
  + ##### Database
    + Dummy DB using Azure SQL Database
+ #### Australia East
  + asdfasdf
+ #### Australia Central
  + asdfasdf

### The Module deploys the following

   - Type some Markdown on the left
   - See HTML in the right
   - Magic

------------
## Caveats

> Although Terrafrom can be used to deploy the infrastructure, it is not possible to manage changes to the routers
> using Terraform post deployment as any modifications to the template file are not seen as a resource change in state,
> therefore, Terraform will not make any changes to the existing CSR routers. Terraform was designed to be an IaC tool
> to automate the buildout of infrastructure, it was never designed for configuration management. If you would like to 
> manage the setup, it would be best to use a tool like Ansible or puppet to manage the ongoing configuration of the 
> deployed infrastructure. Since Ansible is idempotent, it will not redeploy the code on the router if it already exists.

------------
## References

The following links provide more information on the individual technologies and their usage:

* [Cisco CSR1000v](https://www.cisco.com/c/en/us/products/routers/cloud-services-router-1000v-series/index.html) - Information on Cisco CSR1000v architecture and deployment
* [Cisco CSR1000v on Microsoft Azure](https://www.cisco.com/c/en/us/td/docs/routers/csr1000/software/azu/b_csr1000config-azure.html) - Cisco CSR 1000v Deployment Guide for Microsoft Azure
* [Cisco CSR1000v 0 Day Bootstrap on Microsoft Azure](https://www.cisco.com/c/en/us/td/docs/routers/csr1000/software/azu/b_csr1000config-azure/b_csr1000config-azure_chapter_01011.html) - Deploying a Cisco CSR 1000v VM on Microsoft Azure using a Day 0 Bootstrap File
* [Terraform](https://www.terraform.io/) - HashiCorp Terraform Architecture and use
* [Terraform Template Files](https://www.terraform.io/docs/providers/template/d/file.html) - Using Terraform ``` template_file``` function

------------
## Using The Module

Dillinger requires [Node.js](https://nodejs.org/) v4+ to run.

Install the dependencies and devDependencies and start the server.

```sh
$ cd dillinger
$ npm install -d
$ node app
```

For production environments...

```sh
$ npm install --production
$ NODE_ENV=production node app
```

------------
### Plugins

Dillinger is currently extended with the following plugins. Instructions on how to use them in your own application are linked below.

| Plugin | README |
| ------ | ------ |
| Dropbox | [plugins/dropbox/README.md][PlDb] |
| GitHub | [plugins/github/README.md][PlGh] |
| Google Drive | [plugins/googledrive/README.md][PlGd] |
| OneDrive | [plugins/onedrive/README.md][PlOd] |
| Medium | [plugins/medium/README.md][PlMe] |
| Google Analytics | [plugins/googleanalytics/README.md][PlGa] |

------------
### Todos

 - Write MORE Tests
 - Add Night Mode