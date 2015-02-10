#!/bin/bash
# Utility script for making it easier to sign stuff for Keybase.io with an
# airgapped offline key.

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
grep -E "^echo" "${KEYBASE_BLOB_FILE}" | cut -d '|' -f 1 >> "${MAKE_PAYLOAD_SCRIPT}"
chmod a+x "${MAKE_PAYLOAD_SCRIPT}"
"${MAKE_PAYLOAD_SCRIPT}" > "${PAYLOAD_FILE}"

### Make script for signing in airgapped environment ###
cat << EOF > "${SIGN_SCRIPT}"
#!/bin/bash
EOF
# Force usage of main key (prevent gpg from using a subkey instead)
# Also provide the input as a file instead of as stdin
grep -E "^gpg" "${KEYBASE_BLOB_FILE}" | cut -d '|' -f 1 | \
  sed "s/-u '\([0-9a-fA-F]*\)'/-u '\1!'/" | \
  sed "s#sign#sign '${PAYLOAD_FILE}'#" \
  >> "${SIGN_SCRIPT}"
chmod a+x "${SIGN_SCRIPT}"

### Make script for uploading signature ##
cat << EOF > "${UPLOAD_SCRIPT}"
#!/bin/bash
cat "${SIGNED_FILE}" | \\
EOF
grep -A 1000 -E "^perl" "${KEYBASE_BLOB_FILE}" >> "${UPLOAD_SCRIPT}"
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
