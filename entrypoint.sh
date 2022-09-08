#!/bin/sh -l

debug () {
    echo "$(date) -- DEBUG -- $1"
}

image_name=$1
minor_pattern=$2
major_pattern=$3
prefix=""
if [$4 -eq "true"];
then
  prefix="v"
fi

debug "Image name: $image_name"
debug "Minor pattern: $minor_pattern"
debug "Major pattern: $major_pattern"
debug "Prefix: $prefix"

git config --global --add safe.directory /github/workspace

# get the latest image tag
# https://docs.github.com/en/rest/packages#get-all-package-versions-for-a-package-owned-by-the-authenticated-user
container_tags=$(curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user/packages/container/container-image-tag-action/versions | jq -r '.[].metadata.container.tags' | grep -vE "\[|\]" | sed "s/\"//g" | sed "s/ //g")
debug "Container tags: \n$container_tags"

tag="$(semver $container_tags | sort | tail -n 1)"
debug "Last semver container tag: $tag"

# get git history to determine the bump level
git fetch --all
current_branch=$(git rev-parse --abbrev-ref HEAD)
debug "Current branch is $current_branch"

log=$(git log main..$current_branch --pretty='%B')
debug "Git log: $log"

# bump the version
case "$log" in
    *$major_pattern* )
        new_tag=$(semver -i major $tag); part="major"
    ;;
    *$minor_pattern* )
    new_tag=$(semver -i minor $tag); part="minor"
    ;;
    * )
    new_tag=$(semver -i patch $tag); part="patch"
    ;;
esac

debug "$part version bump: $tag -> $new_tag"

echo "::set-output name=imagetag::$new_tag"
