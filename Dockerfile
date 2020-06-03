FROM alpine

RUN apk add curl make git bash

RUN     curl -L -o /tmp/git-secrets.zip https://github.com/awslabs/git-secrets/archive/1.3.0.zip \
    &&  cd /tmp \
    &&  unzip git-secrets.zip \
    &&  cd git-secrets-1.3.0 \
    &&  make install

COPY forbidden-patterns.txt /var

WORKDIR /workspaces/my-repo-with-secrets
COPY secrets-*.txt ./

# initialise the repository
RUN     git init \
    &&  git config user.email "john@example.org" \
    &&  git config user.name "john" \
    &&  git add secrets-1.txt && git commit -m "add secrets-1.txt" \
    &&  git rm secrets-1.txt && git commit -m "remove secrets-1.txt" \
    &&  git add secrets-2.txt && git commit -m "add secrets-2.txt"

# install hooks
RUN git-secrets --install

ENTRYPOINT ["sh", "-s"]
