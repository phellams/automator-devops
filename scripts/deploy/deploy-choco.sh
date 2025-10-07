#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Environment Loading ---
if [ -f build.env ]; then
    source build.env
else
    echo "build.env file not found! Expected variables: BUILD_PACKAGE_NAME, BUILD_PACKAGE_VERSION, CHOCO_NUPKG_PACKAGE_NAME"
    exit 1
fi


choco_query=$(choco search ${BUILD_PACKAGE_NAME} --version ${BUILD_PACKAGE_VERSION} --pre)

for line in $choco_query; do
 echo "Processing: $line"
    choco_version+=($line)
done

# build array using ifs
# print all array elements

if [[ ${choco_version[2]} != '0' ]]; then
    echo "==choco version: ${choco_version[@]}"
    echo "+ choco package found for version ${BUILD_PACKAGE_VERSION}"
    echo " + choco module version: ${choco_version[3]}"
    echo " + Local module version: ${BUILD_PACKAGE_VERSION}"
    exit 0
fi

echo "No choco package found for version ${BUILD_PACKAGE_VERSION}"
echo "continueing deployment..."

echo "Pushing choco package to chocolatey.org"

cd ./dist/choco
# Ensure the package name is set correctly
choco apikey --key "${CHOCO_API_KEY}" --source https://push.chocolatey.org/

# Push the package
choco push "${CHOCO_NUPKG_PACKAGE_NAME}" --source https://push.chocolatey.org/

echo "Choco package pushed successfully."

unset choco_version

# Rename the package to a standard name for future reference
#mv "../choco/${BUILD_PACKAGE_NAME}.${BUILD_PACKAGE_VERSION}.nupkg" "../choco/${CHOCO_NUPKG_PACKAGE_NAME}-choco.nupkg" 



