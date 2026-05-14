# SOPS Keybox

## Key Hierarchy
There are multiple types of keys:
- AK/Application keys: These keys are usable by applications to automatically decrypt certain files. The VP IT is free
to decide what each application key has access to.
- PK/Personal keys: Personal keys belong to an individual. The VP IT is free to decide who does and does not get a 
personal key and the access given to each personal key
- FK/Full recovery key: This single key must be able to decrypt all encrypted files. It is to be stored in the repo and
encrypted with multiple recovery fragment keys.
- RK/Recovery fragment keys: These fragment keys are entrusted to different execs who may use the keys to decrypt the
FK to then decrypt other files.

## Key Recovery
1. Get fk.enc.key from the Google Drive and put it inside keybox/.
2. Combine all recovery fragment keys into a single file. `cat rk*.key > combined-rk.key`
3. Use the combined key file to decrypt the full key. `SOPS_AGE_KEY_FILE=combined-rk.key sops decrypt fk.enc.key --output fk.dec.key`
4. Use the decrypted full key to decrypt other files. `export SOPS_AGE_KEY_FILE=$(pwd)/fk.dec.key`

## Key Transfer Procedure
The procedure should be done on the previous VP IT's machine.
1. Make a copy of the keybox to avoid locking yourself out.
2. Create a new full key. `rm -f fk.dec.key && age-keygen -pq -o fk.dec.key`
3. Create new recovery fragment keys. `age-keygen -pq -o rk-abc.key && age-keygen -pq -o rk-xyz.key`
4. Edit the .sops.yaml file to use the new recovery fragment public keys and the new full public key.
5. Encrypt the new full key and delete the unencrypted full key. `sops encrypt fk.dec.key --output fk.enc.key && rm fk.dec.key`
6. Entrust the recovery fragment keys to different people.
7. Delete the recovery fragment keys from the previous VP IT's machine.
8. The new VP IT should send to the previous VP IT the new public personal keys to use.
9. The previous VP IT should replace all personal keys with the new set of personal keys in the .sops.yaml file. Their
key should no longer be present in the .sops.yaml file.
10. The previous VP IT should run `script/updatekeys.sh` to complete the transfer.
11. The new fk.enc.key file should be uploaded to the Google Drive.