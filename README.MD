# Openstack OVH Lookatch images

![Travis](https://travis-ci.com/Pirionfr/ovh-lookatch-openstack-images.svg?branch=master)

Packer and Ansible scripts to build Openstack base images for lookatch deployment.


## Build

Export your Openstack credentials as environment variables.

```
export OS_PROJECT_ID=xxxxx
export OS_USERNAME=xxxxx
export OS_PASSWORD=xxxxx

export OS_AUTH_URL=xxxxx
export OS_REGION_NAME=xxxx
```

Build lookatch base images used by Terraform for lookatch deployment on OVH
Public Cloud infrastructure:

```./packer.sh```

