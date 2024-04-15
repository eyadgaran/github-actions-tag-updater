# Tag Updater

Push new tags automatically via Github Actions

Configurable to increment last tag with custom prefix, message, and increment amount.

## Input parameters

These are the parameters you can use with the action:

- `message`: [optional] Message for the tag
- `prefix`: [optional] String to be added before the tag, for example if this parameter takes the value "v" the final tag will be "v8.0.0" (can pass branch name as prefix to make versioning per branch)
- `suffix`: [optional] String to be added after the tag, for example if this parameter takes the value "-rc" the final tag will be "v8.0.0-rc"
- `match_suffix`: [optional] Boolean to match the suffix with the last tag, default is true. Can be useful to match latest release version to add pre-release suffix
- `version`: [optional] Version field to be used as the base for the new tag, if not provided the patch version will be incremented. Allowed values are "major", "minor", "patch"
- `increment`: [optional] Increment amount for the version field, default is 1

## Usage

You can configure a workflow like this:

```yaml
name: Tagging

on:
  push:
    branches: 'master'

jobs:
  tag:
    permissions: write-all
    name: Bump tag version
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Create an incremental release
      uses: eyadgaran/github-actions-tag-updater@master
      with:
        version: 'patch'
        increment: '1'
        message: Bump version
        prefix: 'v'
        suffix: ''
        match_suffix: 'true'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

