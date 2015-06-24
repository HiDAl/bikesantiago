#!/bin/bash

lastCheck=''

while [ true ]; do
    ts=`date +"%s"`;
    ruby scrapper.rb > bd/$ts.json;
    check=$(md5sum bd/$ts.json);

    if [[ "$check" -eq "$lastCheck" ]]; then
        rm bd/$ts.json
    fi

    lastCheck=$(md5sum bd/$ts.json);

    sleep 60;
done
