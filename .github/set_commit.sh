#!/bin/bash

set -e

script_dir=$(dirname "$(realpath "$BASH_SOURCE")")

file_path="$script_dir/../$FILE_NAME"

current_commit=$(grep -oP 'commit: "\K[^\"]+' "$file_path")

release_data=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                https://api.github.com/repos/CleverRaven/Cataclysm-DDA/releases -o $script_dir/releases.json)
commit_sha=$(echo "$release_data" | jq -r '.[0].target_commitish' $script_dir/releases.json)
tag_name=$(echo "$release_data" | jq -r '.[0].tag_name' $script_dir/releases.json)

if [[ ! -s $script_dir/releases.json ]]; then
  echo "Error: Failed to retrieve releases data or the response is empty."
  exit 1
fi

if [[ "$commit_sha" == "$current_commit" ]]; then
  echo "Commit is already up to date: $commit_sha"
  rm $script_dir/releases.json
  exit 1
else
  echo "Updating commit from $current_commit to $commit_sha"
  sed -i "s/commit: \"$current_commit\"/commit: \"$commit_sha\"/" "$file_path"
  echo "Updated commit in file: $(grep -oP 'commit: "\K[^\"]+' "$file_path")"
  echo "Release tag name: $tag_name"
  export TAG_NAME="$tag_name"
  rm $script_dir/releases.json
fi
