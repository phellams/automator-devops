#!/bin/bash

if [ -f build.env ]; then
    source build.env
else
    echo "build.env file not found!"
    exit 1
fi

cd ./dist/${BUILD_PACKAGE_NAME}
choco pack --outputdirectory "../choco" 
