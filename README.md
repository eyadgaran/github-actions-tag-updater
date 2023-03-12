# Tag Updater

Push new tags automatically via Github Actions

Configurable to increment last tag (globally or per branch) or apply a fixed tag.

## Input parameters

These are the parameters you can use with the action:

- `increment_branch_tag`: [optional] Whether tag versions should be relative to the current branch or globally in the repo (e.g. latest tag on branch is 2.1.0 and 4.0.0 on another branch)
- `message`: [optional] Message for the tag
- `tag_prefix`: [optional] String to be added before the tag, for example if this parameter takes the value "v" the final tag will be "v8.0.0"

## Usage

You can configure a workflow like this:

```yaml
name: Tagging

on:
  push:
    branches: 'master'

jobs:
  build:
    name: Bump tag
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Create an incremental release
      uses: eyadgaran/github-actions-tag-updater@master
      with:
        increment_branch_tag: true
        message: Bump version
        tag_prefix: 'v'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

