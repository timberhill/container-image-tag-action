#!/bin/sh -l

debug () {
    echo "$(date) -- DEBUG -- $1"
}

image_name=$1
minor_pattern=$2
major_pattern=$3
prefix="v"
if [$4 -eq "false"];
then
  prefix=""
fi

debug "Image name: $image_name"
debug "Minor pattern: $minor_pattern"
debug "Major pattern: $major_pattern"
debug "Prefix: $prefix"

echo "::set-output name=image::$image_name"


# get the latest image tags

container_tags=$(curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user/packages/container/container-image-tag-action/versions | jq -r '.[].metadata.container.tags' | grep -vE "\[|\]" | sed "s/\"//g" | sed "s/ //g")
debug "Container tags: \n$container_tags"

current_container_tag="$(semver $container_tags | tail -n 1)"
debug "Last semver container tag: $current_container_tag"

# get git history to determine the bump level

git fetch --tags
current_branch=$(git rev-parse --abbrev-ref HEAD)
debug "Current branch is $current_branch"



tagFmt="^v?[0-9]+\.[0-9]+\.[0-9]+$" 
taglist="$(git for-each-ref --sort=-v:refname --format '%(refname:lstrip=2)' | grep -E "$tagFmt")"
debug "Tag list $taglist"

tag="$(semver $taglist | tail -n 1)"
debug "Last semver tag is $tag"


log=$(git log $prefix$tag..HEAD --pretty='%B')

debug "Git log: $log"

