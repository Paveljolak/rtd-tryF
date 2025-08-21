#!/bin/bash
set -x

################################################################################
# File:    buildDocs.sh
# Purpose: Build versioned documentation using Sphinx for multiple branches,
#          single language only, then update GitHub Pages.
################################################################################

#####################
# DECLARE VARIABLES #
#####################

pwd
ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)

##############
# INSTALL DEPENDENCIES #
##############
pip install --upgrade pip
pip install -r required_packages.txt

##############
# BUILD DOCS #
##############

# clean previous builds
make -C docs clean

# temp dir for GitHub Pages output
docroot=$(mktemp -d)
export REPO_NAME="${GITHUB_REPOSITORY##*/}"

# branches to build (multiversion logic)
versions=$(git for-each-ref --format='%(refname:lstrip=-1)' refs/remotes/origin/ | grep -viE '^(HEAD|gh-pages)$')

for current_version in ${versions}; do
    git checkout ${current_version}
    export current_version

    echo "INFO: Building docs for branch: ${current_version}"

    # skip if docs folder is missing
    [ ! -e "docs/conf.py" ] && { echo "INFO: 'docs/conf.py' not found (skipped)"; continue; }

    # single language: English
    current_language="en"
    export current_language
    echo "INFO: Building for language: ${current_language}"

    # HTML build
    sphinx-build -b html docs/ docs/_build/html/${current_language}/${current_version} -D language="${current_language}"

    # PDF build
    sphinx-build -b rinoh docs/ docs/_build/rinoh -D language="${current_language}"
    mkdir -p "${docroot}/${current_language}/${current_version}"
    cp "docs/_build/rinoh/target.pdf" "${docroot}/${current_language}/${current_version}/helloWorld-docs_${current_language}_${current_version}.pdf"

    # EPUB build
    sphinx-build -b epub docs/ docs/_build/epub -D language="${current_language}"
    mkdir -p "${docroot}/${current_language}/${current_version}"
    cp "docs/_build/epub/target.epub" "${docroot}/${current_language}/${current_version}/helloWorld-docs_${current_language}_${current_version}.epub"

    # copy static HTML assets
    rsync -av "docs/_build/html/" "${docroot}/"

done

# return to main branch
git checkout main
