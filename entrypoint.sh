#!/bin/sh -l

debug () {
    echo "$(date) -- DEBUG -- $1"
}

image_name=$(echo "$1" | cut -d "/" -f 2)
minor_pattern=${2:-#minor}
major_pattern=${3:-#major}
include_v=${4:-false}
initial_tag=${5:-0.1.0}

prefix=""
if [ "$include_v" = true ]; then
  prefix="v"
fi



debug "Image name: $image_name"
debug "Minor pattern: $minor_pattern"
debug "Major pattern: $major_pattern"
debug "Include 'v': $include_v, prefix: '$prefix'"
debug "Initial tag: $initial_tag"

# get image tags
# https://docs.github.com/en/rest/packages#get-all-package-versions-for-a-package-owned-by-the-authenticated-user
api_response=$(curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user/packages/container/$image_name/versions)
debug "API response: $api_response"

image_exists=$(echo $api_response | jq -r 'if . | type == "array" then "true" else "false" end')
debug "Image exists: $image_exists"
# check if the image exists
if [ "$image_exists" = "false" ]; then
  debug "Image not found, using the initial tag $initial_tag"
  echo "::set-output name=image-tag::$prefix$initial_tag"
  exit 0
fi

# get the container tags
container_tags=$(echo $api_response | jq -r '.[].metadata.container.tags' | grep -vE "\[|\]" | sed "s/\"//g" | sed "s/ //g")
debug "Container tags: $(echo $container_tags | sed "s/\n//g" | sed "s/ /, /g")"
tag="$(semver $container_tags | sort | tail -n 1)"
# check if the image contains previous semver tags
if [ "$tag" = "" ]; then
  debug "Image does not contain any semver tag, using the initial tag $initial_tag"
  echo "::set-output name=image-tag::$prefix$initial_tag"
  exit 0
else
  debug "Last semver container tag: $tag"
fi

# get git history to determine the bump level
log=$(git show --summary --pretty='%B')
debug "Git log: $(echo $log | sed "s/\n//g")"

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

debug "$part version bump: $prefix$tag -> $prefix$new_tag"

echo "::set-output name=image-tag::$prefix$new_tag"
