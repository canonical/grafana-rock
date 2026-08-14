set allow-duplicate-recipes
set allow-duplicate-variables
import? 'rocks.just'

source_repo := 'grafana/grafana'

[private]
@default:
  just --list
  echo ""
  echo "For help with a specific recipe, run: just --usage <recipe>"


# Patch all existing major.minor folders, then sync the grafana-ui source-tag
[group("maintenance")]
update:
  #!/usr/bin/env bash
  set -e
  just --justfile rocks.just update
  # Keep the grafana-ui part's source-tag in sync with the grafana part
  for folder in $(find . -maxdepth 1 -type d -regextype posix-extended -regex '\./[0-9]+\.[0-9]+' -printf '%f\n'); do
    source_tag="$(yq -r '.parts.grafana.source-tag' "$folder/rockcraft.yaml")"
    tag="$source_tag" yq -i '.parts.grafana-ui.source-tag = strenv(tag)' "$folder/rockcraft.yaml"
  done
