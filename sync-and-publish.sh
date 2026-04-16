#!/bin/bash
# sync-and-publish.sh

set -e  # Exit on error

echo "🔄 Syncing from upstream..."
git fetch upstream
git merge upstream/master --no-edit

echo "📁 Reorganizing files into docs directory..."

echo "📂 Moving markdown files to docs/..."
mv X16\ Reference\ -\ *.md docs/ 2>/dev/null || true
cp README.md docs/index.md 2>/dev/null || true

echo " 📄 Converting README.md to index.md in docs/..."
mv docs/README.md docs/index.md 2>/dev/null || true

echo "📂 Moving images to docs/..."
mv images docs/images 2>/dev/null || true

echo "Deleting symlinks in docs/ if they exist..."
find docs/ -type l -exec rm -f {} \; 2>/dev/null || true

echo "📤 Deploying to gh-pages..."
mkdocs gh-deploy

echo "Staging and committing changes..."
git add .
git commit -m "Sync, reorganize files, and prepare for deployment: $(date)" || true

echo "✨ All done! Synced, reorganized, built, and deployed!"
