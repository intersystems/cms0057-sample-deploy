<!-- omit in toc -->
# cms0057-sample-deploy

This repository contains sample deployment files to deploy InterSystems Payer Services Applications as container stacks. Note that these are sample files intended to be used along with the [InterSystems Payer Service user documentation](https://docs.intersystems.com/hs20241/csp/docbook/DocBook.UI.Page.cls?KEY=PAGE_hsps).

**These sample files ARE NOT intended for direct usage in production environments.**

A single Payer Services application consists of a stack with two containers:

- a Web Gateway container
- an InterSystems IRIS For Health&trade; instance container

Below we describe the sample files provided in this repository to deploy such solution applications.
- [Structure](#structure)
- [sample\_deploy](#sample_deploy)
  - [config/iris](#configiris)
  - [deployfiles](#deployfiles)
    - [docker-compose and container.env](#docker-compose-and-containerenv)
    - [web-gateway](#web-gateway)
    - [iam-register-entrypoint.sh](#iam-register-entrypointsh)
    - [iam-services-config.JSON](#iam-services-configjson)
  - [data-ingestion](#data-ingestion)
- [sample\_configs](#sample_configs)


## Structure

This repository is structured into two top level directories: `sample_deploy` and `sample_configs`.
- `sample_deploy` contains the directory structure recommended to deploy a solution container stack. 
While the directory structure can be altered, this requires that you override variables in the environment (.env) files.
- `sample_configs` contains example files for configuring Payer Services components.

## sample_deploy

This directory structure is as follows:
```
📦sample_deploy
 ┣ 📂config
 ┃ ┗ 📂iris
 ┃ ┃ ┣ 📜iris.key (iam or non-iam)
 ┃ ┃ ┗ 📜merge.cpf
 ┣ 📂deployfiles
 ┃ ┗ 📂web-gateway
 ┃ ┃ ┗ 📂certificate
 ┃ ┃ ┃ ┣ 📜ssl-cert.key
 ┃ ┃ ┃ ┗ 📜ssl-cert.pem
 ┃ ┃ ┣ 📜CSP.conf
 ┃ ┃ ┗ 📜CSP.ini
 ┃ ┣ 📜iam-register-entrypoint.sh
 ┃ ┣ 📜iam-services-config.json
 ┃ ┣ 📜container.env
 ┃ ┗ 📜docker-compose.yml
 ┣ 📂data-ingestion
 ┃ ┗ 📂Data

```

Below we break down the roles of the various directories and files. For directories and files whose locations can be changed, the corresponding environment variables that control the directory locations are also referenced. Note that the directory-related environment variables are optional. If you do not specify directory-related environment variable values, then you **must** use the default directory structure referenced in the above image and detailed below.

### config/iris

This directory contains all necessary configuration-related files used at container deployment time for InterSystems IRIS-specific configuration.  
**NOTE:** Any files under this directory are NOT used during the active lifetime of the  container. Other storage locations are used for storing data needed during the lifetime of a running container.

This directory MUST consist of, at a minimum, an iris.key file for the license key of the corresponding solution image that is being deployed. If you wish to use InterSystems API Manager features for your solution, then you must use an IAM-enabled license.

It is also required that a merge.cpf file be included if there are any startup-related configuration settings. The example file provided sets up the API Manager for your solution. The IAM Password needs to be set in this file (and the value should match the IAM_USER_PWD environment variable).

Environment variables related to this directory: 
- `EXTERNAL_IRIS_CONFIG_DIRECTORY`
- `ISC_CONFIG_DIRECTORY`
- `ISC_CPF_MERGE_FILE_NAME`

### deployfiles
All deployment related files. This includes:

- [docker-compose and container.env files](#docker-compose-and-container.env)
- [web gateway deployment files](#web-gateway)
- [IAM setup script](#iam-register-entrypoint.sh)
- [IAM configuration json file](#iam-services-config.JSON)

#### docker-compose and container.env

To deploy the container stack, the following command is run:
```bash
docker-compose -f docker-compose.yml --env-file=cms0057.container.env up
```

This command will configure a single Payer Services application stack consisting of two containers: Web Gateway instance and IRIS For Health instance.

However, before this can be run, the values in `.container.env` need to be populated. The file itself describes what each variable does and this is further fleshed out in the InterSystems Payer Services user documentation.  
In the sections below, when environment variables are referenced, they will only be referenced by name and their description can be looked up in one of the above-referenced sources.

You will notice that the variables themselves, or their corresponding defaults in the `docker-compose.yml` file, point to other relative directories or files which are referenced in the next few sections. There are two docker-compose samples provided, one of which has IAM enabled.

#### web-gateway

This subdirectory contains the files necessary to deploy an InterSystems Web Gateway image. which is documented in the [InterSystems Web Gateway documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCGI).

If you are already familiar with the InterSystems Web Gateway, a sample docker-compose file for deploying an InterSystems Web Gateway is provided in the [InterSystems Community gitub repo](https://github.com/intersystems-community/webgateway-examples/tree/master/demo-compose).

#### iam-register-entrypoint.sh

An entrypoint script, containing curl calls to register settings with the IAM container. You should not have to edit this.

#### iam-services-config.JSON

A JSON file that contains IAM settings information. Edit this file to identify each Payer Services component that you deploy as one of the  "services".

### data-ingestion

This directory does not exist in the sample directory structure but you can create it on your host, along with the `Data` subdirectory as a bind mount.

Environment variables related to this directory: 
- `EXTERNAL_ISC_DATA_ROOT_DIRECTORY`
- `ISC_DATA_ROOT_DIRECTORY`

## sample_configs

This directory contains sample files for your solution application.