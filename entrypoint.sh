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
echo "increment_branch_tag: ${INPUT_INCREMENT_BRANCH_TAG}"
echo "message: ${INPUT_MESSAGE}"
echo "tag_prefix: ${INPUT_TAG_PREFIX}"
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
    echo "branch: ${branch}";

    last_tag=`git describe --tags $(git rev-list --tags) --always|egrep "${branch}-${INPUT_TAG_PREFIX}\.[0-9]*\.[0-9]*\.[0-9]*$"|sort -V -r|head -n 1`
    echo "Last tag: ${last_tag}";
else
    last_tag=`git describe --tags $(git rev-list --tags --max-count=1)`
    echo "Last tag: ${last_tag}";
fi


if [ -z "${last_tag}" ];then
    if [ "${INPUT_INCREMENT_BRANCH_TAG}" != false ];then
        last_tag="${branch}-${INPUT_TAG_PREFIX}0.0.0";
    else
        last_tag="${INPUT_TAG_PREFIX}0.0.0";
    fi
    echo "Default Last tag: ${last_tag}";
fi

next_tag="${last_tag%.*}.$((${last_tag##*.}+1))"
echo "3) Next tag: ${next_tag}";

echo "4) Forcing tag update..."
git tag -a ${next_tag} -m "${INPUT_MESSAGE}" "${GITHUB_SHA}" -f
echo "5) Pushing tag..."
git push --tags
