# Configuration file for the Sphinx documentation builder.
import os
import sys
from git import Repo

# -- Project information -----------------------------------------------------
project = 'my-docs'
copyright = '2025, pavel'
author = 'pavel'
release = '1.0.0'
version = release  # Added for EPUB compatibility

# -- General configuration ---------------------------------------------------
extensions = ['sphinx_rtd_theme']
templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# Add source code path
sys.path.insert(0, os.path.abspath('../src'))

# -- Options for HTML output -------------------------------------------------
html_theme = 'sphinx_rtd_theme'
# html_static_path = ['_static']  # Commented out to avoid warning; uncomment if custom static files are needed

# -------------------------------
# Multi-version (branch) support
# -------------------------------
try:
    html_context
except NameError:
    html_context = dict()

html_context['display_lower_left'] = True
html_context['display_github'] = True
html_context['github_user'] = 'Paveljolak'
html_context['github_repo'] = 'rtd-tryF'
html_context['github_version'] = 'main/docs/'

# Repo name for URLs
REPO_NAME = os.environ.get('REPO_NAME', 'rtd-tryF')

# Single language build (English)
current_language = os.environ.get('current_language', 'en')
html_context['current_language'] = current_language

# Determine current version from env or git branch
repo = Repo(search_parent_directories=True)
current_version = os.environ.get('current_version', repo.active_branch.name)
html_context['current_version'] = current_version
html_context['version'] = current_version

# Links to other versions (branches)
html_context['versions'] = [
    ('main', f'/{REPO_NAME}/{current_language}/main/'),
    ('jazzy', f'/{REPO_NAME}/{current_language}/jazzy/')
]

# Links to downloads (PDF/EPUB)
html_context['downloads'] = [
    ('pdf', f'/{REPO_NAME}/{current_language}/{current_version}/my-docs_{current_language}_{current_version}.pdf'),
    ('epub', f'/{REPO_NAME}/{current_language}/{current_version}/my-docs_{current_language}_{current_version}.epub')
]
