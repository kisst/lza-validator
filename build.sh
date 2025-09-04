#!/bin/bash -eu
set -o pipefail

# Recent n releases of LZA
n=1

# Container tooling choice (docker/finch/...)
tooling=docker

if [ ! -d landing-zone-accelerator-on-aws ]; then
  git clone https://github.com/awslabs/landing-zone-accelerator-on-aws.git
fi
cd landing-zone-accelerator-on-aws
git checkout main
git pull
# Filter for stable releases only (exclude alpha, beta, rc, experimental, pre-release versions)
stable_tags=$(git tag | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V)
latest_n_releases=$(echo $stable_tags | rev | cut -d ' ' -f 1-$n | rev)
cd ..

for release in $latest_n_releases; do
  cd landing-zone-accelerator-on-aws
  git -c advice.detachedHead=false checkout $release
  cd ..
  echo $release
  $tooling build --build-arg $release --tag lza-validator:$release .
done
