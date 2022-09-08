# Container image tag action

[![Tag image](https://github.com/timberhill/container-image-tag-action/actions/workflows/tag-image.yaml/badge.svg)](https://github.com/timberhill/container-image-tag-action/actions/workflows/tag-image.yaml)

A Github Action to bump an image version in ghcr.io, allowing separate versioning of the repo and multiple container images that are built within it.

The action only works with [semantic versions](semver.org).
It is also only checks the latest commit for that, as it's designed to run on a PR merge to the main branch. Make sure to include the major/minor pattern (see inputs) in the PR title.

## Inputs

### `image`
  _(required)_ Path to the image within ghcr.io (`<OWNER>/<IMAGE_NAME>`)

### `minor-pattern`
  (default: `#minor`) Commit message pattern that indicates a minor version bump

### `major-pattern`
  (default: `#major`) Commit message pattern that indicates a major version bump

### `include-v`
  (default: `false`) Whether or not to include `v` prefix in the version"

## Outputs

### `image-tag`
  New version tag

## Example usage

```yaml
- name: Bump image version
  id: action
  uses: timberhill/container-image-tag-action@main
  with:
    image: ${{ env.IMAGE }}
  env:
    GITHUB_TOKEN: "${{ secrets.PAT }}"

- name: New image tag
  run: echo "${{ steps.action.outputs.image-tag }}"
```

A full example workflow is used in this repo: [.github/workflows/tag-image.yaml](.github/workflows/tag-image.yaml)
