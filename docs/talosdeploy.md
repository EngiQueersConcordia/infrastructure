# Talos Linux Deploment

## apply-config
You need to add --insecure for the initial setup

Use script/deploy.sh to deploy Talos configuration to a node

### ENA
#### Image configuration
https://factory.talos.dev/?arch=amd64&board=undefined&bootloader=auto&cmdline=-console+console%3Dtty1+console%3DttyS0&cmdline-set=true&extensions=-&platform=metal&secureboot=undefined&target=metal&version=1.13.2

baremetal

```
customization:
    extraKernelArgs:
        - -console
        - console=tty1
        - console=ttyS0
```


### Jenny
#### Image configuration
https://factory.talos.dev/?arch=amd64&platform=metal&schematic-id=9ed5fecdacb36b5c5427b87d409f1065cfb2df69b0f71c58b868d9d466d8dab3&secureboot=true&target=metal&version=1.13.2

baremetal-secureboot