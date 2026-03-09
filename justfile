set allow-duplicate-recipes
set allow-duplicate-variables
import? 'rocks.just'

[private]
@default:
  just --list
  echo ""
  echo "For help with a specific recipe, run: just --usage <recipe>"


# Generate a rock for the latest version of the upstream project
[arg("source_repo", help="Repository of the upstream project in 'org/repo' form")]
[group("maintenance")]
update source_repo:
  #!/usr/bin/env bash
  just --justfile rocks.just update {{source_repo}}
  # Additional update steps (Grafana UI)
  latest_release="$(gh release list --repo {{source_repo}} --exclude-pre-releases --limit=1 --json tagName --jq '.[0].tagName')"
  # Explicitly filter out prefixes for known rocks, so we can notice if a new rock has a different schema
  version="${latest_release}"
  version="${version#mimir-}"  # mimir
  version="${version#cmd/builder/v}"  # opentelemetry-collector
  version="${version#v}"  # Generic v- prefix
  # Substitute the additional version reference
  source_tag="$(yq .parts.grafana.source-tag "$version/rockcraft.yaml")"
  tag="$source_tag" yq -i '.parts.grafana-ui.source-tag = strenv(tag)' "$version/rockcraft.yaml"
