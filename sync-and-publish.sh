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

echo "🏗️ Building documentation..."
mkdocs build

# echo "Deleting docs/ directory from git tracking..."
# git rm -r --cached docs/ 2>/dev/null || true

echo "Staging and committing changes..."
git add .
git commit -m "Sync with upstream, reorganize files, and prepare for deployment: $(date)" || true

# cp -r site ../_site_temp

echo "📤 Deploying to gh-pages..."
mkdocs gh-deploy
# git branch -f gh-pages master
# git checkout gh-pages
# # rm -rf *
# cp -r ../_site_temp/* .
# git add -A
# git commit -m "Deploy to gh-pages: $(date)" || true
# git push origin gh-pages

# echo "📤 Deploying to rtd branch..."
# git branch -f rtd master
# git checkout rtd
# # rm -rf *
# cp -r ../_site_temp/* .
# git add -A
# git commit -m "Deploy to rtd: $(date)" || true
# git push origin rtd

# echo "✅ Back to master..."
# git checkout master

echo "✨ All done! Synced, reorganized, built, and deployed!"
