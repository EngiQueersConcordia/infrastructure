# LUKS key backup

Jenny is encrypted using LUKS to protect the data stored on it. For disaster recovery purposes, the LUKS volume key
is backed up to an encrypted file in keybox/luks_keys.yaml. The keys are protected by SOPS.

## Acquiring the volume key
1. Run `talosctl -n jenny.engiqueersconcordia.ca debug ubuntu`
2. Run `apt update && apt install --no-install-recommends -y cryptsetup`
3. Run `cryptsetup luksDump --dump-volume-key /dev/sda3`. Use the key in talos/patches/jenny/disk.yaml for STATE.
4. Run `cryptsetup luksDump --dump-volume-key /dev/sda4`. Use the key in talos/patches/jenny/disk.yaml for EPHEMERAL.
5. Run `cryptsetup luksDump --dump-volume-key /dev/sda5`. Use the key in talos/patches/jenny/disk.yaml for openebs.
6. The keys should be stored in keybox/luks_keys.yaml and encrypted with SOPS.

## Using the volume key
The LUKS volume key can be used to decrypt the disk using cryptsetup. To unlock a partition, use
`cryptsetup open --volume-key-file <volumekeyfile> /dev/<partition>`