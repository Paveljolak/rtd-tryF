#!/bin/bash
set -x

pwd
ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)

# Install dependencies
pip install --upgrade pip
pip install -r required_packages.txt

# Clean previous builds
make -C docs clean

# Temp dir for GitHub Pages output
docroot=$(mktemp -d)
export REPO_NAME="${GITHUB_REPOSITORY##*/}"

# Branches to build
versions=$(git for-each-ref --format='%(refname:lstrip=-1)' refs/remotes/origin/ | grep -viE '^(HEAD|gh-pages)$')

for current_version in ${versions}; do
    git checkout ${current_version}
    export current_version

    echo "INFO: Building docs for branch: ${current_version}"

    # Skip if docs folder is missing
    [ ! -e "docs/conf.py" ] && { echo "INFO: 'docs/conf.py' not found (skipped)"; continue; }

    # Single language: English
    current_language="en"
    export current_language
    echo "INFO: Building for language: ${current_language}"

    # HTML build directly to docroot
    sphinx-build -b html docs/ "${docroot}/${current_language}/${current_version}" -D language="${current_language}"

    # PDF build
    sphinx-build -b rinoh docs/ docs/_build/rinoh -D language="${current_language}"
    mkdir -p "${docroot}/${current_language}/${current_version}"
    cp "docs/_build/rinoh/my-docs.pdf" "${docroot}/${current_language}/${current_version}/my-docs_${current_language}_${current_version}.pdf" || echo "PDF build failed"

    # EPUB build
    sphinx-build -b epub docs/ docs/_build/epub -D language="${current_language}"
    mkdir -p "${docroot}/${current_language}/${current_version}"
    cp "docs/_build/epub/my-docs.epub" "${docroot}/${current_language}/${current_version}/my-docs_${current_language}_${current_version}.epub" || echo "EPUB copy failed"
done

# Return to main branch
git checkout main

# Deploy to gh-pages
cd "$docroot"
git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add .
git commit -m "Deploy docs for ${GITHUB_SHA}"
git push --force "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" HEAD:gh-pages || { echo "Push to gh-pages failed"; exit 1; }
cd -
