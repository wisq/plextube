#!/bin/sh

cd "$1"
shift
exec youtube-dl "$@"
