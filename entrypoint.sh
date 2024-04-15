#!/bin/sh
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
    git config --global user.email "actions@github.com"
    git config --global user.name "Tag Updater GitHub Action"
}

echo "###################"
echo "Tagging Parameters"
echo "###################"
echo "Version to Increment: ${INPUT_VERSION}"
echo "Increment Amount: ${INPUT_INCREMENT}"
echo "Tag Message: ${INPUT_MESSAGE}"
echo "Tag Prefix: ${INPUT_PREFIX}"
echo "Tag Suffix: ${INPUT_SUFFIX}"
echo "Match Suffix: ${INPUT_MATCH_SUFFIX}"
echo "GITHUB_ACTOR: ${GITHUB_ACTOR}"
echo "GITHUB_TOKEN: ${GITHUB_TOKEN}"
echo "HOME: ${HOME}"
echo "###################"
echo ""
echo "Start process..."

echo "1) Setting up git machine..."
git_setup

echo "2) Updating repository tags..."
git fetch origin --tags --quiet

# Get last tag
if [ -n "${INPUT_MATCH_SUFFIX}" ]; then
    last_tag=`git describe --tags $(git rev-list --tags) --always|egrep "${INPUT_PREFIX}\.[0-9]*\.[0-9]*\.[0-9]*${INPUT_SUFFIX}$"|sort -V -r|head -n 1`
else
    last_tag=`git describe --tags $(git rev-list --tags) --always|egrep "${INPUT_PREFIX}\.[0-9]*\.[0-9]*\.[0-9]*$"|sort -V -r|head -n 1`
fi
echo "Last Tag: ${last_tag}";

# Default first tag
if [ -z "${last_tag}" ];then
    last_tag="0.0.0";
    echo "Default First tag: ${last_tag}";
fi

# Extract major, minor, and patch versions from the last tag
major_version=$(echo "${last_tag}" | awk -F'.' '{print $1}')
minor_version=$(echo "${last_tag}" | awk -F'.' '{print $2}')
patch_version=$(echo "${last_tag}" | awk -F'.' '{print $3}')

# Increment the version based on the value of INPUT_VERSION
if [ "${INPUT_VERSION}" = "major" ]; then
    next_major_version=$((major_version + ${INPUT_INCREMENT}))
    next_minor_version=0
    next_patch_version=0
elif [ "${INPUT_VERSION}" = "minor" ]; then
    next_major_version=${major_version}
    next_minor_version=$((minor_version + ${INPUT_INCREMENT}))
    next_patch_version=0
elif [ "${INPUT_VERSION}" = "patch" ]; then
    next_major_version=${major_version}
    next_minor_version=${minor_version}
    next_patch_version=$((patch_version + ${INPUT_INCREMENT}))
else
    echo "Invalid value for INPUT_VERSION: ${INPUT_VERSION}"
    exit 1
fi

# Construct the next tag
next_tag="${INPUT_PREFIX}${next_major_version}.${next_minor_version}.${next_patch_version}${INPUT_SUFFIX}"

echo "3) Next Tag: ${next_tag}";

echo "4) Forcing tag update..."
git tag -a ${next_tag} -m "${INPUT_MESSAGE}" "${GITHUB_SHA}" -f
echo "5) Pushing tag..."
git push --tags
