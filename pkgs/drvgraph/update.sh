#!/usr/bin/env nix-shell
#! nix-shell -i bash -p cabal2nix hpack jq curl git nixfmt

set -euo pipefail

pkgdir=$(cd -- "$(dirname -- "$(realpath "$0")")" && pwd)

old_version=$(sed -nE 's/^[[:space:]]*version = "([^"]*)";/\1/p' "${pkgdir}/generated.nix")

owner="StarryReverie"
repo="DrvGraph"
branch="main"
subpath="hs-packages/drvgraph"

rev="${1:-$(git ls-remote "https://github.com/${owner}/${repo}.git" "refs/heads/${branch}" | cut -f '1')}"
if [ -z "${rev}" ]; then
  echo "error: failed to resolve revision" >&2
  exit 1
fi

archive="https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"

hash=$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --type sha256 --print-path "${archive}" | sed -n '1p')")
srcdir=$(nix-prefetch-url --type sha256 --unpack --print-path "${archive}" | sed -n '2p')

date=$(curl -fsSL "https://api.github.com/repos/${owner}/${repo}/commits/${rev}" | jq -r '.commit.committer.date[:10]')

base=$(sed -nE 's/^version:[[:space:]]*//p' "${srcdir}/${subpath}/package.yaml")
version="${base}-unstable-${date}"

tmpdir=$(mktemp -d)
trap 'rm -rf "${tmpdir}"' EXIT
cp -r --no-preserve=mode "${srcdir}/." "${tmpdir}/src"

cabal2nix "${tmpdir}/src" \
  --hpack \
  --subpath "${subpath}/" \
  --src-expression 'src' \
  --extra-arguments 'src' \
  > "${pkgdir}/generated.nix"

sed -i -E "s|version = \"[^\"]*\";|version = \"${version}\";|" "${pkgdir}/generated.nix"

cat > "${pkgdir}/sources.json" <<EOF
{
  "rev": "${rev}",
  "hash": "${hash}"
}
EOF

nixfmt "${pkgdir}/generated.nix"

git -C "${pkgdir}" add .
git -C "${pkgdir}" commit -m "pkgs/drvgraph: ${old_version} -> ${version}" .
