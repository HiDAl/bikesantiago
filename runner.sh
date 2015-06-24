#!/bin/bash

lastCheck=''

while [ true ]; do
    ts=`date +"%s"`;
    ruby scrapper.rb > bd/$ts.json;
    check=$(openssl md5 bd/$ts.json | awk '{print $2}');
    echo $check $lastCheck
    if [ "$check" = "$lastCheck" ]; then
        echo "equals"
        rm bd/$ts.json
    fi

    lastCheck=$(openssl md5 bd/$ts.json | awk '{print $2}');

    sleep 3;
done
