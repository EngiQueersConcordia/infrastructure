Procedure to replace an existing linux OS with talos without mounting an iso

1. Create an image at https://factory.talos.dev with the right params
2. On the target machine, wget the kernel-amd64, cmdline-metal-amd64 and initramfs-amd64.xz files
3. On the target machine, install kexec-tools
4. On the target machine, prepare to boot with kexec: `sudo kexec --load kernel-amd64 --initrd=initramfs-amd64.xz --command-line="$(cat cmdline-metal-amd64)"`
5. On the target machine, execute the new kernel: `sudo kexec --exec`
6. The machine will now boot talos as if it was mounted as an iso