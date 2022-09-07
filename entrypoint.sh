#!/bin/sh -l

log () {
    echo "$(date) -- $1"
}

log "Image name: $1"
log "Minor pattern: $2"
log "Major pattern: $3"

echo "::set-output name=image::$1"
