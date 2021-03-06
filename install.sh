#!/bin/bash -xe

if [[ -z "$1" ]]; then echo "usage: install.sh <image-name>"; exit 1; fi

readonly t=$(date +%s)
readonly image_name="$1"
readonly mnt_dir="/tmp/matlab_iso_$t"
readonly extract_dir="${EXTRACT_DIR:-/tmp/matlab_iso}"
readonly license_dat=/tmp/MATLAB.dat
readonly installer_conf="$extract_dir/installer.conf"

if [ -z "${ML_ISO_DIR}" ]; then echo "ML_ISO_DIR was not specified"; exit 1; fi
if [ -z "${FIK}" ]; then echo "FIK was not specified"; exit 1; fi

if [[ "$IS_LM" -eq 1 ]]; then
  readonly install_cmd="$extract_dir/install -mode silent -agreeToLicense yes -fileInstallationKey $FIK -destinationFolder /usr/local/matlab -inputFile $installer_conf -licensePath $license_dat -lmgrFiles true"
else
  if [ -z "${LM_HOST_ID}" ]; then echo "LM_HOST_ID was not specified"; exit 1; fi
  if [ -z "${LM_HOST_NAME}" ]; then LM_HOST_NAME="$HOSTNAME"; fi
  if [ -z "${LM_HOST_PORT}" ]; then LM_HOST_PORT=27000; fi
  readonly install_cmd="$extract_dir/install -mode silent -agreeToLicense yes -fileInstallationKey $FIK -destinationFolder /usr/local/matlab -inputFile $installer_conf -licensePath $license_dat"
fi

echo "Installing MATLAB from source in $ML_ISO_DIR"
ls -d ${ML_ISO_DIR}/*.iso

if [ ! -d "$extract_dir" ]; then
  mkdir "$extract_dir"

  if [ ! -d "$mnt_dir" ]; then mkdir "$mnt_dir"; fi
  for iso in $(ls -d ${ML_ISO_DIR}/*.iso); do
    sudo mount "$iso" "$mnt_dir"
    sudo cp -R ${mnt_dir}/* "$extract_dir"
    sudo umount "$mnt_dir"
  done
  rmdir "$mnt_dir"
fi

cat products > "$installer_conf"

if [[ "$IS_LM" -eq 1 ]]; then
  touch "$license_dat"
else
cat <<EOF > "$license_dat"
SERVER $LM_HOST_NAME $LM_HOST_ID $LM_HOST_PORT
USE_SERVER
EOF
fi

cid=$(docker run -d -v "$license_dat:$license_dat:ro" -v "$extract_dir:$extract_dir:ro" "$image_name" ${install_cmd})
docker logs -f "$cid"

if [[ "$IS_LM" -eq 1 ]]; then
     docker commit --change='CMD ["/usr/libexec/s2i/lmstart.sh"]' "$cid" "$image_name"
else docker commit --change='CMD ["/usr/libexec/s2i/usage"]'  "$cid" "$image_name"; fi

docker rm "$cid"
