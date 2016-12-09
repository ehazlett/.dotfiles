#!/bin/bash

PKGS="github.com/golang/lint/golint
golang.org/x/tools/cmd/goimports
github.com/jessfraz/riddler
github.com/Masterminds/glide"

for PKG in $PKGS; do
    go get -v -u $PKG
done
