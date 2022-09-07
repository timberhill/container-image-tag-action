#!/bin/sh -l

log () {
    echo "$(date) -- $1"
}

log $1
echo "::set-output name=image::$1"
