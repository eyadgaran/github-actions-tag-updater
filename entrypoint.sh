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
echo "Version by Branch: ${INPUT_INCREMENT_BRANCH_TAG}"
echo "Version Increment: ${VERSION_INCREMENT}"
echo "Tag Message: ${INPUT_MESSAGE}"
echo "Tag Prefix: ${INPUT_TAG_PREFIX}"
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

last_tag=""
if [ "${INPUT_INCREMENT_BRANCH_TAG}" = true ];then
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Branch: ${branch}";

    last_tag=`git describe --tags $(git rev-list --tags) --always|egrep "${branch}-${INPUT_TAG_PREFIX}\.[0-9]*\.[0-9]*\.[0-9]*$"|sort -V -r|head -n 1`
    echo "Last Branch Tag: ${last_tag}";
else
    last_tag=`git describe --tags $(git rev-list --tags --max-count=1)`
    echo "Last Tag: ${last_tag}";
fi


if [ -z "${last_tag}" ];then
    if [ "${INPUT_INCREMENT_BRANCH_TAG}" != false ];then
        last_tag="${branch}-${INPUT_TAG_PREFIX}0.0.0";
    else
        last_tag="${INPUT_TAG_PREFIX}0.0.0";
    fi
    echo "Default Last tag: ${last_tag}";
fi

# Extract major, minor, and patch versions from the last tag
major_version=$(echo "${last_tag}" | awk -F'.' '{print $1}')
minor_version=$(echo "${last_tag}" | awk -F'.' '{print $2}')
patch_version=$(echo "${last_tag}" | awk -F'.' '{print $3}')

# Increment the version based on the value of VERSION_INCREMENT
if [ "${VERSION_INCREMENT}" = "major" ]; then
    next_major_version=$((major_version + 1))
    next_minor_version=0
    next_patch_version=0
elif [ "${VERSION_INCREMENT}" = "minor" ]; then
    next_major_version=${major_version}
    next_minor_version=$((minor_version + 1))
    next_patch_version=0
elif [ "${VERSION_INCREMENT}" = "patch" ]; then
    next_major_version=${major_version}
    next_minor_version=${minor_version}
    next_patch_version=$((patch_version + 1))
else
    echo "Invalid value for VERSION_INCREMENT: ${VERSION_INCREMENT}"
    exit 1
fi

# Construct the next tag
if [ "${INPUT_INCREMENT_BRANCH_TAG}" = true ];then
    next_tag="${branch}-${INPUT_TAG_PREFIX}${next_major_version}.${next_minor_version}.${next_patch_version}"
else
    next_tag="${INPUT_TAG_PREFIX}${next_major_version}.${next_minor_version}.${next_patch_version}"
fi

echo "3) Next Tag: ${next_tag}";

echo "4) Forcing tag update..."
git tag -a ${next_tag} -m "${INPUT_MESSAGE}" "${GITHUB_SHA}" -f
echo "5) Pushing tag..."
git push --tags
