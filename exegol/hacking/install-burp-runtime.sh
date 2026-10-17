#!/bin/sh
# Run inside Exegol hacking. Download the official runtime and verify SHA-512.
set -eu
profile=/opt/my-resources/setup/zsh/hacking
archive=jbr-21.0.11-linux-x64-b1163.116.tar.gz
url="https://cache-redirector.jetbrains.com/intellij-jbr/$archive"
sha512=ac3e29d91c00bab01d292adfa8b1a357195263acf4e3ca7429df142a5b4fed05fddf87ce657dbb77dfa544993009ed3814f2ad03e409d0d0ebf49ca95910d26b

[ "$(uname -m)" = x86_64 ] || { echo 'Este runtime es para x86_64.' >&2; exit 1; }
if [ -x "$profile/jbr-21/bin/java" ]; then
    "$profile/jbr-21/bin/java" -version
    exit 0
fi
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
curl --fail --location --retry 3 "$url" --output "$work/$archive"
printf '%s  %s\n' "$sha512" "$work/$archive" | sha512sum --check -
mkdir -p "$profile/jbr-21"
tar xzf "$work/$archive" --strip-components=1 -C "$profile/jbr-21"
"$profile/jbr-21/bin/java" -version
