# Talos Linux Deploment

## apply-config
You need to add --insecure for the initial setup

### ENA
```bash
patches=(patches/ena/*.yaml patches/worker/*.yaml patches/all/*.yaml)
talosctl apply-config --insecure --nodes ena.engiqueersconcordia.ca --file worker.dec.yaml ${patches[*]/#/--config-patch }
```