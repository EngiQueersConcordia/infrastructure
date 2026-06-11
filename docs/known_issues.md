# Rebooting Jenny
Talos currently does not have first party support for LVM. As such, reboots will hang on attempting to close the openebs
encrypted volume. You may manually close the LVM volume by running
`talosctl debug -n jenny.engiqueersconcordia.ca alpine --args 'sh,-c,apk add lvm2 && vgchange -an openebs'`.