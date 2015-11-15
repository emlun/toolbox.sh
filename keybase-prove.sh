#!/bin/bash
# Utility script for making it easier to sign stuff for Keybase.io with an
# airgapped offline key.
#
# Usage:
# 1. Set the `REMOVABLE_DEVICE_UUID` below (see `$ lsblk -o +FSTYPE,UUID`)
# 2. Go to keybase.io and add a new key or proof, track someone etc.
# 3. Choose to sign manually
# 4. Copy the script to the Xorg primary clipboard (should be enough to just
#    select it all - triple-clicking the text box does the trick in Firefox)
# 5. Run this script
# 6. Move the removable device to the airgapped machine and mount it
# 7. Sign the payload (`keybase.json`). You can use the `keybase-sign.sh`
#    script written to the removable device for this, note that it assumes the
# drive is mounted at the same mount point on both machines.
# 8. Unmount and move the removable device back to your internet-connected
#    machine. This script (which should still be running) should take care of
#    the rest.

REMOVABLE_DEVICE_UUID="c5cd54f0-dd6e-4928-be23-dab8a874109b"
MOUNTPOINT=/mnt/usb
BASEDIR="${MOUNTPOINT}/keybase"
KEYBASE_BLOB_FILE="$(mktemp)"
MAKE_PAYLOAD_SCRIPT="$(mktemp)"
SIGN_SCRIPT="${BASEDIR}/keybase-sign.sh"
UPLOAD_SCRIPT="${BASEDIR}/keybase-finish.sh"
PAYLOAD_FILE="${BASEDIR}/keybase.json"
SIGNED_FILE="${PAYLOAD_FILE}.asc"

sudo mount -U ${REMOVABLE_DEVICE_UUID} "${MOUNTPOINT}"
sudo mkdir -p "${BASEDIR}"
sudo chown -R $(whoami) "${BASEDIR}"

### Read text blob from keybase script window ###
xclip -o > "${KEYBASE_BLOB_FILE}"

### Make payload to sign ###
cat << EOF > "${MAKE_PAYLOAD_SCRIPT}"
#!/bin/bash
EOF
grep -E "^\s*echo" "${KEYBASE_BLOB_FILE}" | cut -d '|' -f 1 >> "${MAKE_PAYLOAD_SCRIPT}"
chmod a+x "${MAKE_PAYLOAD_SCRIPT}"
"${MAKE_PAYLOAD_SCRIPT}" > "${PAYLOAD_FILE}"

### Make script for signing in airgapped environment ###
cat << EOF > "${SIGN_SCRIPT}"
#!/bin/bash
EOF
# Force usage of main key (prevent gpg from using a subkey instead)
# Also provide the input as a file instead of as stdin
grep -E "^\s*gpg" "${KEYBASE_BLOB_FILE}" | cut -d '`' -f 1 | \
  sed "s/-u '\([0-9a-fA-F]*\)'/-u '\1!'/" | \
  sed "s#sign#sign '${PAYLOAD_FILE}'#" \
  >> "${SIGN_SCRIPT}"
chmod a+x "${SIGN_SCRIPT}"

### Make script for uploading signature ##
cat "${KEYBASE_BLOB_FILE}" | \
  grep -vE "^\s*echo" | \
  grep -vE "^\s*gpg" | \
  sed "s#--data-urlencode sig=.*#--data-urlencode sig@${SIGNED_FILE} \\\\#" \
  > "${UPLOAD_SCRIPT}"
chmod a+x "${UPLOAD_SCRIPT}"

sudo umount "${MOUNTPOINT}"


### Do it ###

echo "Waiting for removable device ${REMOVABLE_DEVICE_UUID} to disappear"
while lsblk -l -o +UUID | grep -q ${REMOVABLE_DEVICE_UUID}; do
  sleep 1
done

echo "Removable device disappeared. Now run the signing script on the airgapped machine."

echo "Waiting for removable device ${REMOVABLE_DEVICE_UUID} to appear"
until lsblk -l -o +UUID | grep -q ${REMOVABLE_DEVICE_UUID}; do
  sleep 1
done

sudo mount -U ${REMOVABLE_DEVICE_UUID} "${MOUNTPOINT}"

echo "Running upload script"

"${UPLOAD_SCRIPT}"
