<!-- omit in toc -->
# cms0057-sample-deploy

This repository contains sample deployment files to deploy InterSystems Payer Services solutions. Note that these are sample files intended to be used along with the [InterSystems Payer Service user documentation](https://docs.intersystems.com/hslatest/csp/docbook/DocBook.UI.Page.cls?KEY=HSPSDeploy_intro).

**These sample files ARE NOT intended for direct usage in production environments.**

A single Payer Services application (component) consists of a stack with two containers:

- a Web Gateway container
- an InterSystems IRIS For Health&trade; instance container
  
A separate InterSystems API Manager (IAM) container stack can be deployed to manage the APIs for all of the Payer Services solution applications that you deploy.

Below we describe the sample files provided in this repository to deploy Payer Services solution applications.
- [Repository Structure](#repository-structure)
- [sample\_deploy](#sample_deploy)
  - [config/iris](#configiris)
  - [web-gateway](#web-gateway)
  - [docker-compose-hp and hp.container.env](#docker-compose-hp-and-hpcontainerenv)
  - [docker-compose-iam and iam.container.env](#docker-compose-iam-and-iamcontainerenv)
  - [iam-register-entrypoint.sh](#iam-register-entrypointsh)
  - [iam-services-config.JSON](#iam-services-configjson)
- [sample\_configs](#sample_configs)

## Repository Structure

This repository is structured into two top level directories: `sample_deploy` and `sample_configs`.
- `sample_deploy` contains the directory structure recommended to deploy the component and IAM container stacks. 
While the directory structure can be altered, this requires that you override variables in the environment (.env) files.
- `sample_configs` contains example files for configuring Payer Services components and InterSystems API Manager.

## sample_deploy

This directory has the following sample files for container stack deployment. Note that it includes deployment files for both Payer Services and InterSystems API Manager (IAM) containers in a single directory. Each product, however, runs in its own independent container stack.

The Payer Services container stack deployment files include:
  - IRIS configurations under `./config/`, including:
    - iris.key
    - merge.cpf
  - web-gateway deployment files under `./web-gateway/`, including:
    - SSL certificates
    - web gateway configurations
  - docker-compose-hp.yml
  - hp.container.env

The IAM container stack deployment files include:
  - docker-compose-iam.yml
  - iam.container.env
  - iam-register-entrypoint.sh
  - iam-services-config.JSON

The (combined) directory structure is as follows:
```
📦sample_deploy
 ┣ 📂config
 ┃ ┗ 📂iris
 ┃   ┣ 📜iris.key (iam or non-iam)
 ┃   ┗ 📜merge.cpf
 ┣ 📂web-gateway
 ┃ ┣ 📂certificate
 ┃ ┃ ┣ 📜ssl-cert.key
 ┃ ┃ ┗ 📜ssl-cert.pem
 ┃ ┣ 📜CSP.conf
 ┃ ┗ 📜CSP.ini
 ┣ 📜hp.container.env
 ┣ 📜iam.container.env
 ┣ 📜docker-compose-hp.yml
 ┣ 📜docker-compose-iam.yml
 ┣ 📜iam-register-entrypoint.sh
 ┗ 📜iam-services-config.json
```

Below we break down the roles of the various directories and files. For directories and files whose locations can be changed, the corresponding environment variables that control the directory locations are also referenced. Note that the directory-related environment variables are optional. If you do not specify directory-related environment variable values, then you **must** use the default directory structure referenced in the above image and detailed below.

### config/iris

This directory contains all necessary configuration-related files used at container deployment time for InterSystems IRIS-specific configuration.  

**NOTE:** 
 - Any files under this directory are NOT used during the active
   lifetime of the container. Other storage locations are used for
   storing data needed during the lifetime of a running container.
  - No data ingestion directory is provided by default. You may pass data
   into a service using the REST APIs.

This directory MUST consist of, at a minimum, an `iris.key` file for the license key of the corresponding solution image that is being deployed. If you wish to use InterSystems API Manager features for your solution, then you must use an IAM-enabled license.

It is also required that a `merge.cpf` file be included if there are any startup-related configuration settings. The example file provided sets up the API Manager for your solution. The IAM Password needs to be set in this file (and the value should match the IAM_USER_PWD environment variable in `iam.container.env`).

Environment variables related to this directory: 
- `EXTERNAL_IRIS_CONFIG_DIRECTORY`
- `ISC_CONFIG_DIRECTORY`
- `ISC_CPF_MERGE_FILE_NAME`

### web-gateway

This subdirectory contains the files necessary to deploy an InterSystems Web Gateway image, which is documented in the [InterSystems Web Gateway documentation](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GCGI).

If you are already familiar with the InterSystems Web Gateway, a sample docker-compose file for deploying an InterSystems Web Gateway is provided in the [InterSystems Community Github repo](https://github.com/intersystems-community/webgateway-examples/tree/master/demo-compose).

### docker-compose-hp and hp.container.env

To deploy the Payer Services solution container stack, run the following command from within `./sample-deploy`:
```bash
docker-compose -f docker-compose-hp.yml --env-file hp.container.env up
```

This command configures a single Payer Services application stack consisting of two containers: a Web Gateway instance and an IRIS for Health instance.

However, before this can be run, the values in `hp.container.env` must be populated. The file itself describes what each variable does and this is further fleshed out in the [InterSystems Payer Services user documentation](https://docs.intersystems.com/hslatest/csp/docbook/DocBook.UI.Page.cls?KEY=HSPSDeploy_container#HSPSDeploy_container_env_file) and you can see the usage in the  `docker-compose-hp.yml` file.  

You will notice that the variables themselves, or their corresponding defaults in the `docker-compose.yml` file, point to other relative directories or files.

### docker-compose-iam and iam.container.env
To deploy the Intersystems API Manager container stack, run the following command from within `./sample-deploy/`:
```bash
docker-compose -f docker-compose-iam.yml --env-file iam.container.env up
```
However, before this can be run, the values in `iam.container.env` must be populated. The file itself describes what each variable does and this is further fleshed out in the [InterSystems Payer Services user documentation](https://docs.intersystems.com/hslatest/csp/docbook/DocBook.UI.Page.cls?KEY=HSPSDeploy_apimgr) and you can see the usage in the `docker-compose-iam.yml` file.  

This command configures a single IAM stack consisting of 4 containers: iam, iam-register, iam-migrations, and db.

This IAM stack is independent from solution container stack, it uses an http connection to communicate with Payer Services APIs configured with IAM. Make sure your solution container stack and IAM stack are within the same network subnet.

You also need `iam-register-entrypoint.sh` and `iam-services-config.JSON` configured in order to deploy IAM and  use it with your solution stack:

### iam-register-entrypoint.sh

Required for IAM. An entrypoint script, containing curl calls to register settings with the IAM container. You should not have to edit this.

### iam-services-config.JSON

Required for IAM. A JSON file that contains IAM settings information. Edit this file to identify each Payer Services component that you deploy as one of the "services".

 - The `url` of the service should be a FQDN pointing to the solution component container.
 - Under each service, you may add one or more routes to match requests:
   - Each route should have its unique `name` and `paths`(as a prefix in IAM-redirected endpoint, e.g. unique instance name)                             
   - Use `https` for `protocol`, and set `strip path` to `true`.

## sample_configs

This directory contains sample configuration files for your solution application. The configs are not for direct use and are subject to changes.