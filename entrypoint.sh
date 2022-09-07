#!/bin/sh -l

log () {
    echo "$(date) -- $1"
}

echo "Image name: $1"
time=$(date)
echo "::set-output name=time::$time"

log $1
