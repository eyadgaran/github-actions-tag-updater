FROM alpine/git:1.0.7

LABEL "com.github.actions.name"="Create an incremental tag"
LABEL "com.github.actions.description"="Create an incremental tag under your conditions"
LABEL "com.github.actions.icon"="tag"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/eyadgaran/github-actions-tag-updater"
LABEL "homepage"="https://github.com/eyadgaran/github-actions-tag-updater"
LABEL "maintainer"="Elisha Yadgaran <ElishaY@alum.mit.edu>"

RUN apk add coreutils

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
