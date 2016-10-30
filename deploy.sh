#!/bin/bash

FILE="./publish/theindex.html"

if [ -f "$FILE" ];
then
    echo "Rename $FILE to index.html" >&2
else
    git subtree push --prefix publish origin gh-pages
fi
