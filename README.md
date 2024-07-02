<!-- omit in toc -->
# cms0057-sample-deploy

This repository contains sample deployment files to deploy InterSystems Payer Services Applications as container stacks. Note that these are sample files intended to be used along with the [HealthShare user documentation](https://docs.intersystems.com/hs202311/csp/docbook/DocBook.UI.Page.cls).

**These sample files ARE NOT intended for direct usage in production environments.**

A single HealthShare application consists of a stack with two containers:
a Web Gateway container and a HealthShare instance container.
Below we describe the sample files provided in this repository to deploy such HealthShare applications.

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
- `sample_configs` contain example configuration json files for configuring the different types of applications.

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

Below we break down the roles of the various directories and files. For directories/
files whose locations can be changed, the corresponding environment variables that 
control the directory locations are also referenced. Note that the directory related 
environment variables are optional. If you do not specify directory-related environment
variable values, then you **must** use the default directory structure referenced in 
the above image and detailed below.

### config/iris

This directory contains all necessary configuration related files used at container 
deployment time for InterSystems IRIS-specific configuration.
**NOTE:** Any files under this directory are NOT used during the active lifetime of the 
container. Other storage locations are used for storing data needed during the 
lifetime of a running container.

This directory MUST consist of at a minimum, an iris.key file for the license key 
of the corresponding solution image that is being deployed. It has to ba an IAM enabled license to be able to use InterSystems API Manager features for solution.

It is also required that a merge.cpf file be included for any startup related 
configuration settings. The example file provided sets up API for your solution. IAM Password needs to be set in this file.

Environment variables related to this directory: 
- `EXTERNAL_IRIS_CONFIG_DIRECTORY`
- `ISC_CONFIG_DIRECTORY`
- `ISC_CPF_MERGE_FILE_NAME`

### deployfiles
All deployment related files. This includes docker-compose/container.env files, webgateway deployment files, and IAM setup scipt with configuration json file.


#### docker-compose and container.env

To deploy the container stack, the following command is run:
```bash
docker-compose -f docker-compose.yml --env-file=cms0057.container.env up
```

This command will configure a single payer service application stack consisting of two containers: Web Gateway and IRIS For Health instance.

However, before this can be run, the values in `.container.env` need to be populated. The file itself describes what each of the variables does and this is further fleshed out in the HS user documentation. 
In below sections, when environment variables are referenced, they will only be referenced
by name and their description can be looked up in one of the above referenced sources.

You will notice that the variables themselves or their corresponding defaults in the `docker-compose.yml` file point to other relative directories/files which are referenced in the next few sections.

#### web-gateway

This sub-directory contains the files necessary to deploy an InterSystems 
Web Gateway image which is documented in the [InterSystems Web Gateway documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCGI).

If you are already familiar with the InterSystems Web Gateway, here is a 
[sample docker-compose file](https://github.com/intersystems-community/webgateway-examples/tree/master/demo-compose) 
for deploying an InterSystems Web Gateway.

#### iam-register-entrypoint.sh

An entrypoint script, containing curl calls to register settings with the IAM container

#### iam-services-config.JSON

A JSON file, containing IAM settings info

### data-ingestion

This directory does not exist in the sample directory structure but should be created 
as well as the `Data` sub-directory.

Environment variables related to this directory: 
- `EXTERNAL_ISC_DATA_ROOT_DIRECTORY`
- `ISC_DATA_ROOT_DIRECTORY`


## sample_configs

This directory contains sample JSON objects for your solution application.