#!/bin/sh

if [[ "$(docker images -q git-secrets-example 2>/dev/null)" == "" ]]; then
  echo "Building the Docker container first..."
  docker build . -q -t git-secrets-example
fi

docker run -i --rm git-secrets-example <<EOF
  echo "adding forbidden patterns"
  git secrets --add token
  git secrets --add-provider -- cat /var/forbidden-patterns.txt
  echo "scanning the current source tree"
  git secrets --scan
  echo "scanning the entire history"
  git secrets --scan-history
EOF