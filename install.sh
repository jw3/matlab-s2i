#!/bin/bash -xe

readonly image_name="$1"
readonly t=$(date +%s)
readonly mnt_dir="/tmp/matlab_iso_$t"
readonly extract_dir=/tmp/matlab_iso
readonly license_dat=/tmp/MATLAB.dat
readonly installer_conf="$extract_dir/installer.conf"

if [ -z "${ML_ISO_DIR}" ]; then echo "ML_ISO_DIR was not specified"; exit 1; fi
if [ -z "${LM_HOST_ID}" ]; then echo "LM_HOST_ID was not specified"; exit 1; fi
if [ -z "${LM_HOST_NAME}" ]; then LM_HOST_NAME="$HOSTNAME"; fi
if [ -z "${LM_HOST_PORT}" ]; then LM_HOST_PORT=27000; fi

if [ -z "${FIK}" ]; then echo "FIK was not specified"; exit 1; fi
readonly install_cmd="$extract_dir/install -mode silent -agreeToLicense yes -fileInstallationKey $FIK -licensePath $license_dat -destinationFolder /usr/local/matlab -inputFile $installer_conf"

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

cat <<EOF > "$license_dat"
SERVER $LM_HOST_NAME $LM_HOST_ID $LM_HOST_PORT
USE_SERVER
EOF

cid=$(docker run -d -v "$license_dat:$license_dat" -v "$extract_dir:$extract_dir:ro" "$image_name" ${install_cmd})
docker logs -f "$cid"
docker commit "$cid" matlab:compiler

# todo;; test
#matlab -nosplash -nojvm -nodesktop -nodisplay -r "version, exit"
