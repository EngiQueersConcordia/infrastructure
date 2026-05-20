# Talos Linux Deploment

## apply-config
You need to add --insecure for the initial setup

[//]: # (// TODO create script to run apply with decrypted values)

### ENA
#### Talos config
https://factory.talos.dev/?arch=amd64&board=undefined&bootloader=auto&cmdline=-console+console%3Dtty1+console%3DttyS0&cmdline-set=true&extensions=-&platform=metal&secureboot=undefined&target=metal&version=1.13.2
baremetal
```
customization:
    extraKernelArgs:
        - -console
        - console=tty1
        - console=ttyS0
```

```bash
patches=(patches/ena/*.yaml patches/worker/*.yaml patches/all/*.yaml)
talosctl apply-config --insecure --nodes ena.engiqueersconcordia.ca --file worker.dec.yaml ${patches[*]/#/--config-patch }
```

### Jenny
#### Talos config
https://factory.talos.dev/?arch=amd64&platform=metal&schematic-id=9ed5fecdacb36b5c5427b87d409f1065cfb2df69b0f71c58b868d9d466d8dab3&secureboot=true&target=metal&version=1.13.2
baremetal-secureboot


## Backup LUKS volume key